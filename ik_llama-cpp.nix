{ inputs }:
self: super: {
  ik_llama-cpp-git =
    with super;
    stdenv.mkDerivation (
      finalAttrs:
      let
        # Пин апстрима: релизных тегов у ik_llama.cpp нет (только стаб t0002),
        # см. research/nix-overlays/git-version-packaging.
        srcRev = "656036d98503e154952f6c633cb3febc1a4f08b4";
        # Реквизиты для build-info (в tarball'е .git нет → git-ветка не сработает):
        # 5194 = rev-list --count main на момент пина srcRev.
        buildNumber = "5194";
        buildCommit = "656036d9";
      in
      {
        pname = "ik_llama-cpp";
        version = "unstable-2026-11-06";

        # fetchGit с ref без rev невозможен в pure-mode (flake eval падает:
        # "in pure evaluation mode, 'fetchGit' doesn't fetch unlocked input"),
        # поэтому пиним rev + hash. Подмодулей нет (.gitmodules пуст).
        src = fetchFromGitHub {
          owner = "ikawrakow";
          repo = "ik_llama.cpp";
          rev = srcRev;
          hash = "sha256-YFmWG0/TO3bfC26+yo6NVP3JDchuAOtXsC9aCHnQKBc=";
        };

        # --print-stats / --no-print-stats / --stats-interval N: тонкий вывод
        # таймингов и периодической статистики пропуска сервером.
        # ik-llama-json-schema-pattern: разрешить JSON Schema pattern без ^...$
        # якорей (opencode падал с kimi code 2.7 при tool calling).
        patches = [
          ./patches/ik-llama-stats-interval.patch
          ./patches/ik-llama-json-schema-pattern.patch
          ./patches/ik-llama-f8-e4m3.patch
          ./patches/ik-llama-kimi-k3.patch
          ./patches/ik-llama-kimi-k3-requires-all.patch
          ./patches/ik-llama-deepseek41-kimi-fix.patch
        ];


        # Build includes build_kimi_k3.cpp from patches
        prePatch = ''
          cp ${./patches/build_kimi_k3.cpp} src/graphs/build_kimi_k3.cpp
        '';

        # Базовый уровень инструкций — AVX2. -march=native не использовать:
        # сборка идёт на удалённых билдерах, целевая машина неизвестна.
        # ggml сам включает -mavx/-mavx2/-mfma (GGML_AVX/AVX2=ON при
        # GGML_NATIVE=OFF), здесь флаги распространяются на common/examples/server.
        NIX_CFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";
        NIX_CXXFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";

        buildInputs = [
          openssl
        ];

        nativeBuildInputs = [
          cmake
          ninja
        ];

        postPatch = ''
          # cmake/build-info.cmake безусловно пишет 0/unknown (в mainline тот же
          # код стоит под if (NOT DEFINED ...)), поэтому --version показывал
          # "0 (unknown)". Правим сами: -DBUILD_NUMBER/-DBUILD_COMMIT туда
          # всё равно не попадают, а git-ветка в песочнице не сработает — .git нет.
          substituteInPlace cmake/build-info.cmake \
            --replace-fail 'set(BUILD_NUMBER 0)' \
              'set(BUILD_NUMBER ${buildNumber})' \
            --replace-fail 'set(BUILD_COMMIT "unknown")' \
              'set(BUILD_COMMIT "${buildCommit}")'

          # build_kimi_k3.cpp копируется prePatch, но CMakeLists.txt
          # перечисляет графы явно — добавляем в список.
          sed -i '/graphs\/build_spark2_5.cpp/a\            graphs/build_kimi_k3.cpp' src/CMakeLists.txt
        '';

        cmakeFlags = with self.lib; [
          (cmakeBool "GGML_NATIVE" false)
          # Примеры выключать нельзя: llama-server собирается из examples/
          # (add_subdirectory(examples) стоит под if (LLAMA_BUILD_EXAMPLES)).
          (cmakeBool "LLAMA_BUILD_EXAMPLES" true)
          (cmakeBool "LLAMA_BUILD_SERVER" true)
          (cmakeBool "LLAMA_BUILD_TESTS" false)
          (cmakeBool "LLAMA_OPENSSL" true)
          (cmakeBool "BUILD_SHARED_LIBS" true)
          (cmakeBool "GGML_CUDA" false)
          (cmakeBool "GGML_METAL" false)
          (cmakeBool "GGML_RPC" true)
          (cmakeBool "GGML_VULKAN" false)
          (cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
        ];

        postInstall = ''
          mkdir -p $out/include
          cp $src/include/llama.h $out/include/
        '';

        # Бинарники реально запускаются (линковка/рипаф после fixup).
        doInstallCheck = true;
        installCheckPhase = ''
          runHook preInstallCheck
          "$out"/bin/llama-cli --version
          "$out"/bin/llama-server --version
          runHook postInstallCheck
        '';

        meta = {
          description = "llama.cpp fork with better CPU performance and extra quantization types";
          homepage = "https://github.com/ikawrakow/ik_llama.cpp";
          license = lib.licenses.mit;
          mainProgram = "llama-server";
          platforms = lib.platforms.unix;
        };
      }
    );
}
