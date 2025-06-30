{ inputs }:
self: super: {
  llama-cpp-vulkan-git =
    with super;
    (llama-cpp.override {
      #      stdenv = llvmPackages.stdenv;
      vulkanSupport = true;
      blasSupport = true;

    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/ggerganov/llama.cpp";
          ref = "master";
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
          "-DGGML_VULKAN:BOOL=TRUE"
          "-DGGML_BLAS:BOOL=TRUE"
          #            "-DGGML_SYCL:BOOL=TRUE"
          #            "-DGGML_SYCL_F16:BOOL=TRUE"
        ];
        buildInputs =
          with llvmPackages;
          old.buildInputs
          ++ [
            self.shaderc_my
            openmp
          ];
      });
}
