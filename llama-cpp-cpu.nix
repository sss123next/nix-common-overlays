{ inputs }:
self: super: {
  llama-cpp-cpu-git =
    with super;
    (llama-cpp.override {
      #      stdenv = llvmPackages.stdenv;
      vulkanSupport = false;
      blasSupport = true;
      rpcSupport = true;

    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          #          url = "https://github.com/ggerganov/llama.cpp";
          #          ref = "master";
          url = "https://github.com/ikawrakow/ik_llama.cpp";
          ref = "main";
          submodules = true;
          #            rev = "";
        };
        #          buildInputs = old.buildInputs ++ [ vpl-gpu-rt libvpl ];
        #          patches = [ /home/sss/.config/nixpkgs/patches/libaom-cpp-revert_dry_sampler.patch ];
        postPatch = "";
        postInstall = "";
        NIX_CFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -fno-finite-math-only -O3";
        #          NIX_CXXFLAGS_COMPILE = "-std=c++20 -Ofast -mavx -mavx2 -mssse3 -mfma -mf16c -fno-finite-math-only";
        NIX_CXXFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -fno-finite-math-only -O3";
        cmakeFlags = old.cmakeFlags ++ [
          "-DGGML_VULKAN:BOOL=FALSE"
          "-DGGML_BLAS:BOOL=TRUE"
          "-DLLAMA_BUILD_SERVER:BOOL=TRUE"
          "-DLLAMA_STANDALONE:BOOL=TRUE"
#          "-DGGML_CPU_AARCH64=OFF"
          #            "-DGGML_SYCL:BOOL=TRUE"
          #            "-DGGML_SYCL_F16:BOOL=TRUE"
        ];
        buildInputs =
          with llvmPackages;
          old.buildInputs
          ++ [
            shaderc
            openmp
          ];
      });
}
