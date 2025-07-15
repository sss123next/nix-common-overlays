{ inputs }:
self: super: {
  libavif_my =
    with super;
    (libavif.override {
      libaom = self.libaom_my;
      libyuv = self.libyuv_my;
      dav1d = self.dav1d_my;
    }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/AOMediaCodec/libavif";
          ref = "main";
          rev = "a4fec908b582fd7b82c86014a68e54dc5e0f4058";
        };
        cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DAVIF_LIBYUV_ENABLED=ON" ];
        patches = [];
      });
}
