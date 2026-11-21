{ inputs }:
self: super: {
  qwen-code =
    with super;
    stdenv.mkDerivation (finalAttrs: rec {
      pname = "qwen-code";
      version = "0.28.3-unstable-2026-11-21";

      src = fetchFromGitHub {
        owner = "QwenLM";
        repo = "qwen-code";
        # main @ 2026-11-21
        rev = "b62d4ab7fa384c7308e2d08babb095f65509bf5b";
        sha256 = "sha256-8h5MCrMl2P4jrRqk4kemeAgH9ZGNrYvdceyL8OFOz5E=";
      };

      # v0.24.x switched from npm to pnpm (pnpm-lock.yaml, lockfileVersion 9):
      # fetchPnpmDeps + consumer flow via the hook; pnpm >= 11 requires fetcher version 4.
      pnpm = pnpm_11;

      nativeBuildInputs = [
        nodejs_26
        pnpm
        pnpmConfigHook
      ];

      buildInputs = [
        ripgrep
        glib
        libsecret
      ]
      # exec'ed by the postPatch below (POSIX ps replacement); Linux-only (procps).
      ++ lib.optionals stdenv.hostPlatform.isLinux [ procps ];

      # Full monorepo install (no --filter): devDependencies are needed at build time
      # (tsx for generate-settings-schema.ts, esbuild plugins) and all runtime externals must be present.
      pnpmWorkspaces = [ ];

      pnpmDeps = fetchPnpmDeps {
        inherit pname version src pnpm;
        pnpmWorkspaces = [ ];
        fetcherVersion = 4;
        hash = "sha256-P+mKEcMmcKzUS7aOxBx468U2zk+Do/y6pgWnXCZtFw4=";
      };

      # Upstream now sets MAX_DOCUMENT_RUNTIME_BYTES = 2_132_000 (>= our 2_100_000 patch);
      # the web-templates+budget patch is no longer needed.
      patches = [ ];

      # Upstream hardcodes '/bin/ps' (packages/acp-bridge/src/process-registry.ts POSIX_PS, and
      # the desktop-relay process identity probe). /bin/ps does not exist on NixOS, so the ACP
      # child process-tree snapshot taken during daemon shutdown fails with
      # "spawn /bin/ps ENOENT" and the daemon logs "ACP child shutdown failed"/"shutdown
      # incomplete" (children still die, but only forcefully). Point it at procps: the store path
      # is substituted into the bundle, so it is scanned into the runtime closure automatically.
      # --replace-fail on the process-registry file makes the next upstream move of that constant
      # a loud build error instead of a silent regression.
      postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
        psBin=${lib.getExe' procps "ps"}
        substituteInPlace packages/acp-bridge/src/process-registry.ts \
          --replace-fail "'/bin/ps'" "'$psBin'"
        substituteInPlace packages/node-repl/src/desktop-relay/runtime.ts \
          --replace "'/bin/ps'" "'$psBin'"
      '';

      buildPhase = ''
        runHook preBuild

        export NODE_OPTIONS="--max-old-space-size=4096"

        # scripts/build.js (cli-only): generate git commit info, then build the cli closure (+ repl-mcp + channel-plugin-example).
        node scripts/generate-git-commit-info.js

        # Upstream applies patches/ink+7.0.3.patch in root postinstall via patch-package; Nixpkgs' pnpm hooks disable lifecycle scripts, so run it explicitly (offline, local only).
        ./node_modules/.bin/patch-package || pnpm --offline exec patch-package

        pnpm -r --filter "{./packages/cli}..." \
             --filter "@qwen-code/node-repl-mcp" \
             --filter "@qwen-code/channel-plugin-example" \
             --filter "@qwen-code/generated-ui" run build

        # The settings-schema step of "pnpm generate".
        node --import tsx/esm scripts/generate-settings-schema.ts

        # The bundle step: esbuild + copy assets into dist/.
        node esbuild.config.js && node scripts/copy_bundle_assets.js

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/share/qwen-code
        cp -r dist/* $out/share/qwen-code/

        # pnpm keeps dependencies in a virtual store (node_modules/.pnpm) with relative links;
        # materialize everything as plain files so the copy is self-contained and leaves no symlinks.
        nm=$out/share/qwen-code/node_modules
        mkdir -p "$nm"
        tar -C node_modules --dereference -cf - . | tar -xf - -C $nm

        # esbuild leaves these packages unbundled; they resolve at runtime from dist/cli.js, so they must be top-level entries in node_modules.
        # The ones declared by the cli workspace (not root) only live inside .pnpm -- hoist them up along with sibling deps.
        for pkg in \
          "@teddyzhu/clipboard" \
          "@teddyzhu/clipboard-darwin-arm64" \
          "@teddyzhu/clipboard-darwin-x64" \
          "@teddyzhu/clipboard-linux-arm64-gnu" \
          "@teddyzhu/clipboard-linux-x64-gnu" \
          "@teddyzhu/clipboard-win32-arm64-msvc" \
          "@teddyzhu/clipboard-win32-x64-msvc" \
          "sharp"; do
          esc=$(printf '%s' "$pkg" | tr '/' '+')
          if ! d=$(ls -d "$nm/.pnpm/$esc@*" 2>/dev/null | head -1); then continue; fi
          cp -aR "$d/node_modules/." "$nm/"
        done

        # @qwen-code/audio-capture is a "file:" dep of packages/cli; pnpm materializes it under cli's own node_modules (workspace link). Copy its built contents into $nm, dereferencing any symlinks.
        ac_dir="packages/cli/node_modules/@qwen-code/audio-capture"
        test -d "$ac_dir" || { echo "MISSING audio-capture materialization: $ac_dir" >&2; exit 1; }
        mkdir -p "$nm/@qwen-code/audio-capture"
        tar -C "$ac_dir" --dereference -cf - . | tar -xf - -C "$nm/@qwen-code/audio-capture"

        # Everything else is bundled into dist/; the .pnpm store itself can go.
        rm -rf "$nm/.pnpm"

        for p in sharp "@qwen-code/audio-capture" "@teddyzhu/clipboard"; do
          test -d "$nm/$p" || { echo "MISSING runtime external: $p" >&2; exit 1; }
        done

        patchShebangs $out/share/qwen-code
        ln -sf $out/share/qwen-code/cli.js $out/bin/qwen

        runHook postInstall
      '';

      meta = {
        description = "Coding agent that lives in digital world";
        homepage = "https://github.com/QwenLM/qwen-code";
        mainProgram = "qwen";
        license = lib.licenses.asl20;
        platforms = lib.platforms.all;
        maintainers = with lib.maintainers; [
          lonerOrz
        ];
      };
    });
}
