{ inputs }:
self: super: {
  llama-cpp-vulkan-git =
    with super;
    stdenv.mkDerivation (finalAttrs: {
      pname = "llama-cpp-vulkan";
      version = "git"; # try not to break buildsystem
      src = fetchGit {
        url = "https://github.com/ggerganov/llama.cpp";
        ref = "master";
        submodules = true;
      };
      preConfigure = ''
        prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=master"
        prependToVar cmakeFlags "-DLLAMA_BUILD_NUMBER:STRING=13"
      '';
      NIX_CFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";
      NIX_CXXFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";
      buildInputs = [
        self.shaderc_my
        vulkan-headers
        vulkan-loader
        spirv-headers
        openssl
        clblast
        blas
      ];
      nativeBuildInputs = [
        cmake
        spirv-tools
        installShellFiles
        ninja
        pkg-config
      ];
      cmakeFlags = with self.lib; [
        (cmakeBool "GGML_NATIVE" false)
        (cmakeBool "LLAMA_BUILD_EXAMPLES" false)
        (cmakeBool "LLAMA_BUILD_SERVER" true)
        (cmakeBool "LLAMA_BUILD_TESTS" false)
        (cmakeBool "LLAMA_OPENSSL" true)
        (cmakeBool "BUILD_SHARED_LIBS" true)
        (cmakeBool "GGML_BLAS" true)
        (cmakeBool "GGML_CLBLAST" true)
        (cmakeBool "GGML_CUDA" false)
        (cmakeBool "GGML_HIP" false)
        (cmakeBool "GGML_METAL" false)
        (cmakeBool "GGML_RPC" true)
        (cmakeBool "GGML_VULKAN" true)
        (cmakeFeature "LLAMA_BUILD_NUMBER" finalAttrs.version)
        (cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
        "-DLLAMA_BUILD_WEBUI=OFF"
        "-DLLAMA_BUILD_UI=OFF"
      ];
      postInstall = ''
        mkdir -p $out/include
        cp $src/include/llama.h $out/include/
      '';
      meta = {
        description = "Inference of Meta's LLaMA model (and others) in pure C/C++";
        homepage = "https://github.com/ggml-org/llama.cpp";
        license = lib.licenses.mit;
        mainProgram = "llama";
        platforms = lib.platforms.unix;
      };
    });
}
