{ inputs }:
self: super: {
  llama-cpp-vulkan-git =
    with super;
    (llama-cpp-vulkan.override {
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/ggerganov/llama.cpp";
          ref = "master";
          submodules = true;
        };
#        postPatch = "";
#        postInstall = "";
        NIX_CFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -fno-finite-math-only -O3";
        NIX_CXXFLAGS_COMPILE = "-mavx -mavx2 -mssse3 -mfma -mf16c -fno-finite-math-only -O3";
        buildInputs =
          old.buildInputs
          ++ [
            self.shaderc_my
          ];
      });
}
