{ inputs }:
self: super: {
  llama-cpp-vulkan-git =
    with super;
    (llama-cpp-vulkan.override {
    }).overrideAttrs
      (old: rec {
        version = "13"; #try not to break buildsystem
        src = fetchGit {
          url = "https://github.com/ggerganov/llama.cpp";
          ref = "master";
          submodules = true;
        };
         preConfigure = ''
    prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=master"
    prependToVar cmakeFlags "-DLLAMA_BUILD_NUMBER:STRING=13"
  '';
        #        postPatch = "";
        #        postInstall = "";
        NIX_CFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";
        NIX_CXXFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -mbmi2 -fno-finite-math-only -O3";
        buildInputs = old.buildInputs ++ [
          self.shaderc_my
        ];
      });
}
