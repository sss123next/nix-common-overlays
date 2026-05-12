{ inputs }:
self: super: {
  stable-diffusion-cpp-vulkan-git =
    with super;
    (stable-diffusion-cpp.override {
      cudaSupport = false;
      openclSupport = true;
      vulkanSupport = true;
      rocmSupport = false;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/leejet/stable-diffusion.cpp";
          ref = "master";
        };
      });
}
