{ inputs }:
self: super: {
  intel-media-driver =
    with super;
    (intel-media-driver.override { libva = self.libva_my; }).overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/intel/media-driver";
        ref = "master";
      };
      patches = [ ];
      cmakeFlags = oldAttrs.cmakeFlags ++ [
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" #fuck
        "-DENABLE_PRODUCTION_KMD=ON"
        "-DENABLE_KERNELS=ON"
        "-DENABLE_NONFREE_KERNELS=ON"
      ];
    });
}
