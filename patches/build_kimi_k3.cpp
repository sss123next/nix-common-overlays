#include "../llama-build-context.h"
#include "../llama-model.h"
#include "../llama-context.h"
#include "../llama-delta-net.h"

#include <cmath>

//
// Kimi-K3 text model: hybrid KDA (linear) + MLA (full) attention, as in kimi-linear.
// Parts that kimi-linear does not have:
//   1. cross-layer residual attention  (attn_res_block_size)
//   2. latent MoE                      (routed experts run at n_expert_latent)
//   3. situ activation                 (replaces SwiGLU everywhere)
//   4. MLA output gate                 (sigmoid gate before o_proj)
//   5. full-rank KDA gate              (single ssm_g instead of ssm_g_a/ssm_g_b)
//

static ggml_tensor * kimi_k3_situ(
        ggml_context * ctx0,
        ggml_tensor * gate,
        ggml_tensor * up,
        float situ_beta,
        float situ_linear_beta) {
    // situ_simple(gate, up) = tanh(gate/beta) * sigmoid(gate) * up
    // situ_linear: multiply by tanh(up/linear_beta) when linear_beta > 0
    auto g = ggml_mul(ctx0,
            ggml_mul(ctx0,
                ggml_tanh(ctx0, ggml_scale(ctx0, gate, 1.0f / situ_beta)),
                ggml_sigmoid(ctx0, gate)),
            up);
    if (situ_linear_beta > 0.0f) {
        g = ggml_mul(ctx0, g, ggml_tanh(ctx0, ggml_scale(ctx0, up, 1.0f / situ_linear_beta)));
    }
    return g;
}

static ggml_tensor * kimi_k3_res_mix(
        ggml_context * ctx0,
        ggml_tensor * cur,
        ggml_tensor * score,
        const llm_build_cb & cb,
        int il) {
    if (!score) return cur;
    // Element-wise gate: cur += score * cur
    // score is [n_embd], need to multiply each column of cur by score
    // Transpose cur to [n_embd, n_tokens], scale rows, transpose back
    auto cur_t = ggml_cont(ctx0, ggml_transpose(ctx0, cur));
    auto score_2d = ggml_view_2d(ctx0, score, cur->ne[1], 1, score->nb[0], 0);
    auto s_t = ggml_mul(ctx0, cur_t, score_2d);
    auto s = ggml_cont(ctx0, ggml_transpose(ctx0, s_t));
    cb(s, "res_mix", il);
    return ggml_add(ctx0, cur, s);
}

ggml_cgraph * llm_build_context::build_kimi_k3() {
    if (hparams.n_head() == 0 || this->n_tokens == 0) {
        return new_graph_custom();
    }
    LLAMA_LOG_WARN("build_kimi_k3: start n_head=%ld n_tokens=%ld n_ff=%ld n_embd_head_v_mla=%ld n_embd_head_k_mla=%ld\n",
        hparams.n_head(), this->n_tokens, hparams.n_ff(0), hparams.n_embd_head_v_mla(), hparams.n_embd_head_k_mla());
    ggml_cgraph * gf = new_graph_custom();

    const int64_t n_tokens            = this->n_tokens;
    const int64_t n_outputs           = this->n_outputs;
    const int64_t n_head              = hparams.n_head();
    const int64_t attn_res_block_size = hparams.attn_res_block_size;
    const int64_t n_expert_latent     = hparams.n_expert_latent;
    const int64_t n_embd_head_v_mla   = hparams.n_embd_head_v_mla();   // K/Q MLA dim (128)
    const int64_t n_embd_head_v       = hparams.n_embd_head_v_full;    // V value dim (74)
    const int64_t n_embd_head_k_mla   = hparams.n_embd_head_k_mla();
    const int64_t n_embd_head_qk_nope = n_embd_head_k_mla - hparams.n_rot;
    const float   situ_beta           = hparams.situ_beta;
    const float   situ_linear_beta    = hparams.situ_linear_beta;
    const bool    use_attn_res        = attn_res_block_size > 0;
    const bool    use_latent_moe      = n_expert_latent > 0;

    delta_net delta(lctx, batch);

    auto * inp_out_ids = (n_outputs != n_tokens) ? build_inp_out_ids() : nullptr;
    // No KQ_mask needed: we use ggml_diag_mask_inf + ggml_soft_max (without mask)
    // for causal masking.  Calling build_inp_KQ_mask() would create a tensor
    // that llama_decode then tries to update as host memory, but with RPC backend
    // the buffer is not host-accessible.
    lctx.inp_s_seq_qnext = ggml_new_tensor_2d(ctx0, GGML_TYPE_I32, 1, n_tokens);
    cb(lctx.inp_s_seq_qnext, "inp_s_seq_qnext", -1);
    ggml_set_input(lctx.inp_s_seq_qnext);

    ggml_tensor * inp = llm_build_inp_embd(ctx0, lctx, hparams, batch, model.tok_embd, cb);
    ggml_tensor * inpL = inp;
    ggml_tensor * prefix_sum = inpL;

    for (int il = 0; il < (int) hparams.n_layer; ++il) {
        LLAMA_LOG_WARN("build_kimi_k3: layer %d recurrent=%d\n", il, (int)hparams.is_recurrent(il));
        const auto & layer = model.layers[il];

        // ---- attention block ----
        // build_layer_attn_kda handles its own norm internally;
        // for MLA we build norm explicitly below.
        ggml_tensor * cur = nullptr;

        if (hparams.is_recurrent(il)) {
            cur = delta.build_layer_attn_kda(ctx0, gf, prefix_sum, inp_out_ids, il, cb, /*add_residual=*/false);
            cb(cur, "kda_out", il);
        } else {
            // MLA layer (nope-only, no RoPE)
            // Need to norm before attention (KDA does its own, MLA does not)
            cur = llm_build_norm(ctx0, prefix_sum, hparams, layer.attn_norm, nullptr, LLM_NORM_RMS, cb, il);
            cb(cur, "attn_norm", il);

            // Q down-projection
            auto q_a = ggml_mul_mat(ctx0, layer.wq_a, cur);
            auto q_a_norm = llm_build_norm(ctx0, q_a, hparams, layer.attn_q_a_norm, nullptr, LLM_NORM_RMS, cb, il);
            auto q_b = ggml_mul_mat(ctx0, layer.wq_b, q_a_norm);
            cb(q_b, "q", il);

            // KV down-projection (nope-only: all kv_lora_rank used as key)
            // wkv_a_mqa is [n_embd, kv_lora_rank + n_rot]; output has n_rot extra dims
            // even in nope-only mode. Split into latent and rope parts and norm only the latent.
            auto kv_a = ggml_mul_mat(ctx0, layer.wkv_a_mqa, cur);
            auto kv_a_latent = ggml_view_2d(ctx0, kv_a, hparams.n_lora_kv, n_tokens, kv_a->nb[0], 0);
            auto kv_a_norm = llm_build_norm(ctx0, kv_a_latent, hparams, layer.attn_kv_a_norm, nullptr, LLM_NORM_RMS, cb, il);
            // K_B: [n_embd_head_qk_nope, kv_lora_rank, n_head]
            // Transpose wk_b so ne[0]=kv_lora_rank matches kv_a_norm's first dim,
            // then mul_mat yields [n_head*n_embd_head_qk_nope, n_tokens].
            auto wk_b_T = ggml_cont(ctx0, ggml_transpose(ctx0, layer.wk_b));
            auto wk_b_T_2d = ggml_reshape_2d(ctx0, wk_b_T, hparams.n_lora_kv, n_head * n_embd_head_qk_nope);
            auto k_b_2d = ggml_mul_mat(ctx0, wk_b_T_2d, kv_a_norm);
            auto k_b = ggml_reshape_3d(ctx0, k_b_2d, n_embd_head_qk_nope, n_tokens, n_head);
            // V_B: [kv_lora_rank, n_embd_head_v_mla, n_head] — ne[0]=kv_lora_rank, no transpose needed
            auto wv_b_2d = ggml_reshape_2d(ctx0, layer.wv_b, hparams.n_lora_kv, n_head * n_embd_head_v_mla);
            auto v_2d = ggml_mul_mat(ctx0, wv_b_2d, kv_a_norm);
            auto v = ggml_reshape_3d(ctx0, v_2d, n_embd_head_v_mla, n_tokens, n_head);

            // ---- score: K^T @ Q per head ----
            // Q: [n_embd_head_k_mla, n_head, n_tokens] → permute to [d, n_tokens, n_head]
            auto q_3d = ggml_reshape_3d(ctx0, q_b, n_embd_head_k_mla, n_head, n_tokens);
            auto q_perm = ggml_permute(ctx0, q_3d, 0, 2, 1, 3);
            // Slice Q to nope dims (first n_embd_head_qk_nope)
            auto q_nope = ggml_view_3d(ctx0, q_perm, n_embd_head_qk_nope, n_tokens, n_head,
                q_perm->nb[1], q_perm->nb[2], 0);
            // K is [n_embd_head_qk_nope, n_tokens, n_head] — same layout as permuted Q
            // K^T @ Q per head → [n_tokens, n_tokens, n_head]
            auto KQ = ggml_mul_mat(ctx0, k_b, q_nope);
            auto KQ_scaled = ggml_scale(ctx0, KQ, 1.0f / sqrtf((float) n_embd_head_k_mla));
            auto KQ_masked = ggml_diag_mask_inf(ctx0, KQ_scaled, 0);
            auto KQ_soft = ggml_soft_max(ctx0, KQ_masked);
            cb(KQ_soft, "attn_soft", il);

            // ---- V attention: softmax @ V ----
            // V: [d_v, n_tokens, n_head] → transpose to [n_tokens, d_v, n_head]
            auto V_T_2d = ggml_cont(ctx0, ggml_transpose(ctx0,
                ggml_reshape_2d(ctx0, v, n_embd_head_v_mla, n_head * n_tokens)));
            auto V_T_3d = ggml_reshape_3d(ctx0, V_T_2d, n_tokens, n_embd_head_v_mla, n_head);
            auto kqv = ggml_mul_mat(ctx0, V_T_3d, KQ_soft);

            // ---- output projection ----
            // Reshape to [d_v * n_head, n_tokens], apply gate, then wo
            auto o_2d = ggml_reshape_2d(ctx0, kqv, n_embd_head_v_mla * n_head, n_tokens);
            auto attn_gate = ggml_sigmoid(ctx0, ggml_mul_mat(ctx0, layer.attn_gate, cur));
            auto gated = ggml_mul(ctx0, attn_gate, o_2d);
            cur = ggml_mul_mat(ctx0, layer.wo, gated);
            cb(cur, "attn_out", il);
        }

        // Cross-layer attention residual
        if (use_attn_res) {
            fprintf(stderr, "attn_res_score null=%d use_attn_res=%d\n", layer.attn_res_score == nullptr, (int)use_attn_res);
            cur = kimi_k3_res_mix(ctx0, cur, layer.attn_res_score, cb, il);
        }

        LLAMA_LOG_WARN("before add: pfx ne0=%zu ne1=%zu cur ne0=%zu ne1=%zu\n", prefix_sum->ne[0], prefix_sum->ne[1], cur->ne[0], cur->ne[1]);
        prefix_sum = ggml_add(ctx0, prefix_sum, cur);
        fprintf(stderr, "after add: prefix_sum ne0=%zu ne1=%zu\n", prefix_sum->ne[0], prefix_sum->ne[1]);
        prefix_sum = lctx.cvec.apply_to(ctx0, prefix_sum, il);
        cb(prefix_sum, "prefix_sum_attn", il);

        // ---- FFN block ----
        cur = llm_build_norm(ctx0, prefix_sum, hparams, layer.ffn_norm, nullptr, LLM_NORM_RMS, cb, il);
        cb(cur, "ffn_norm", il);

        if ((uint32_t) il < hparams.n_layer_dense_lead) {
            // Dense FFN with situ activation
            LLAMA_LOG_WARN("ffn: cur ne0=%zu ne1=%zu ffn_gate null=%d\n", cur->ne[0], cur->ne[1], layer.ffn_gate == nullptr);
            auto g = ggml_mul_mat(ctx0, layer.ffn_gate, cur);
            auto u = ggml_mul_mat(ctx0, layer.ffn_up,   cur);
            cur = ggml_mul_mat(ctx0, layer.ffn_down, kimi_k3_situ(ctx0, g, u, situ_beta, situ_linear_beta));
            cb(cur, "ffn_out", il);
        } else {
            // MoE: gating + routed experts + shared expert
            // Use ff_n as intermediate size for the dense-lead case too,
            // but for MoE we use n_ff_exp as per-layer expert width.
            // Kimi-K3 uses Latent MoE: experts operate in n_expert_latent-dim space.
            // Down-projection from n_embd→n_expert_latent happens inside
            // llm_build_moe_ffn (after router, before expert weights) via lctx.model.layers[il].ffn_routed_down.
            auto moe_out = llm_build_moe_ffn(ctx0, lctx, cur,
                    layer.ffn_gate_inp, nullptr,
                    layer.ffn_up_exps, nullptr,
                    layer.ffn_gate_exps, nullptr,
                    layer.ffn_down_exps, nullptr,
                    layer.ffn_exp_probs_b,
                    hparams.n_expert, hparams.n_expert_used,
                    LLM_FFN_SITU, hparams.expert_weights_norm,
                    true, hparams.expert_weights_scale,
                    (llm_expert_gating_func_type) hparams.expert_gating_func,
                    cb, il, gf, false,
                    nullptr, nullptr, nullptr, nullptr, nullptr);
            cb(moe_out, "moe_out", il);

            // Project MoE output back to full dimension if latent
            if (use_latent_moe && layer.ffn_routed_up) {
                moe_out = ggml_mul_mat(ctx0, layer.ffn_routed_up, moe_out);
                cb(moe_out, "moe_latent_up", il);
            }

            // Shared expert (full-dim, situ activation)
            auto ffn_shexp = llm_build_ffn(ctx0, lctx, nullptr, cur,
                    layer.ffn_up_shexp,   nullptr, nullptr,
                    layer.ffn_gate_shexp, nullptr, nullptr,
                    layer.ffn_down_shexp, nullptr, nullptr,
                    nullptr,
                    LLM_FFN_SITU, LLM_FFN_PAR, cb, il);
            cb(ffn_shexp, "ffn_shexp", il);

            cur = ggml_add(ctx0, moe_out, ffn_shexp);
            ggml_build_forward_expand(gf, cur);
        }

        // Cross-layer FFN residual
        if (use_attn_res) {
            cur = kimi_k3_res_mix(ctx0, cur, layer.ffn_res_score, cb, il);
        }

        prefix_sum = ggml_add(ctx0, prefix_sum, cur);
        fprintf(stderr, "after add: prefix_sum ne0=%zu ne1=%zu\n", prefix_sum->ne[0], prefix_sum->ne[1]);
        prefix_sum = lctx.cvec.apply_to(ctx0, prefix_sum, il);
        cb(prefix_sum, "l_out", il);

        inpL = prefix_sum;
    }

    // ---- final ----
    auto cur = inpL;

    // Output cross-layer residual mix
    if (use_attn_res) {
        cur = kimi_k3_res_mix(ctx0, cur, model.output_res_score, cb, -1);
    }

    if (inp_out_ids) {
        cur = ggml_get_rows(ctx0, cur, inp_out_ids);
    }

    cur = llm_build_norm(ctx0, cur, hparams, model.output_norm, nullptr, LLM_NORM_RMS, cb, -1);
    cb(cur, "result_norm", -1);

    cur = llm_build_lora_mm(lctx, ctx0, model.output, cur);
    cb(cur, "result_output", -1);

    ggml_build_forward_expand(gf, cur);
    return gf;
}
