{ inputs }:
self: super: {
  llama-cpp-vulkan-git =
    with super;
    stdenv.mkDerivation (finalAttrs: {
      pname = "llama-cpp-vulkan";
      version = "unstable-2026-11-08";

      # fetchGit с ref без rev невозможен в pure-mode (flake eval падает:
      # "in pure evaluation mode, 'fetchGit' doesn't fetch unlocked input"),
      # поэтому пиним rev + hash. Подмодулей нет (.gitmodules отсутствует).
      # Апстрим переехал: ggerganov/llama.cpp -> ggml-org/llama.cpp.
      src = fetchFromGitHub {
        owner = "ggml-org";
        repo = "llama.cpp";
        rev = "7d7f0287530bc8981690f361d8c1627dbae1c99a";
        hash = "sha256-J+NOeQYs1ojNjgogf54BSiBJLhKQj5i8SamBblV5jVg=";
      };

      # Реквизиты для build-info (в tarball'е .git нет → git-ветка не сработает):
      # 12211 = rev-list --count master на момент пина srcRev.
      buildNumber = "12211";
      buildCommit = "7d7f0287";

      # -march=native не использовать: сборка идёт на удалённых билдерах,
      # целевая машина неизвестна. В Nix SOURCE_DATE_EPOCH задан, поэтому
      # GGML_NATIVE_DEFAULT=OFF и ggml сам НЕ включает AVX-флаги (INS_ENB=OFF) —
      # базовый уровень задаём здесь, он покрывает ggml/common/tools.
      NIX_CFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";
      NIX_CXXFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";

      buildInputs = [
        vulkan-headers
        vulkan-loader
        # SPIRV-Headers CONFIG REQUIRED (ggml/src/ggml-vulkan/CMakeLists.txt)
        spirv-headers
        openssl
      ];

      nativeBuildInputs = [
        cmake
        ninja
        installShellFiles
        # glslc — компилятор шейдеров, нужен только на этапе сборки
        # (find_package(Vulkan COMPONENTS glslc REQUIRED)). Через self:
        # оверлей свой, в super его ещё нет.
        self.shaderc_my
      ];

      cmakeFlags = with self.lib; [
        (cmakeBool "GGML_NATIVE" false)
        # Примеры выключены (в актуальном дереве это отдельные игрушки);
        # llama-server/llama-cli живут в tools/ и собираются при
        # LLAMA_BUILD_TOOLS (ON по умолчанию) + LLAMA_BUILD_SERVER.
        (cmakeBool "LLAMA_BUILD_EXAMPLES" false)
        (cmakeBool "LLAMA_BUILD_SERVER" true)
        (cmakeBool "LLAMA_BUILD_TESTS" false)
        # Не пытаемся выполнить npm-сборку UI и HF-скачивание prebuilt UI
        # в песочнице: llama-ui-assets генерит пустой ui.cpp, сервер работает
        # без встроенного веб-интерфейса (как и раньше с LLAMA_BUILD_WEBUI=OFF).
        (cmakeBool "LLAMA_BUILD_UI" false)
        (cmakeBool "LLAMA_USE_PREBUILT_UI" false)
        (cmakeBool "LLAMA_OPENSSL" true)
        # Release без -dev-суффикса в version (как в nixpkgs).
        (cmakeBool "LLAMA_BUILD_IS_DEV" false)
        (cmakeBool "BUILD_SHARED_LIBS" true)
        # CLBlast (GGML_CLBLAST) удалены из апстрима; BLAS upstream/nixpkgs
        # выключают в паре с Vulkan (GGML_BLAS default OFF).
        (cmakeBool "GGML_BLAS" false)
        (cmakeBool "GGML_CLBLAST" false)
        (cmakeBool "GGML_CUDA" false)
        (cmakeBool "GGML_HIP" false)
        (cmakeBool "GGML_METAL" false)
        (cmakeBool "GGML_RPC" true)
        (cmakeBool "GGML_VULKAN" true)
        (cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
        # build-info: git-ветка в песочнице не работает (.git нет в src),
        # а cmake/build-info.cmake безусловно пишет 0/unknown.
        (cmakeFeature "LLAMA_BUILD_NUMBER" finalAttrs.buildNumber)
        (cmakeFeature "LLAMA_BUILD_COMMIT" finalAttrs.buildCommit)
      ];

      # Заголовки (llama.h, ggml*.h) ставит сам CMake (PUBLIC_HEADER),
      # postInstall-копирование больше не нужно.

      # Бинарники реально запускаются (линковка/рипаф после fixup).
      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck
        "$out"/bin/llama-cli --version
        "$out"/bin/llama-server --version
        runHook postInstallCheck
      '';

      postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
        installShellCompletion --cmd llama-server --bash <("$out"/bin/llama-server --completion-bash)
      '';

      meta = {
        description = "Inference of Meta's LLaMA model (and others) in pure C/C++, Vulkan build";
        homepage = "https://github.com/ggml-org/llama.cpp";
        license = lib.licenses.mit;
        mainProgram = "llama";
        platforms = lib.platforms.unix;
      };
    });
}
