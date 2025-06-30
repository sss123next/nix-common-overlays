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
#          rev = "048488e0588b0543d122ec95ac1a4f54cc73285a";
                                  rev = "963c4bb918bee37cf1ccbd81efa5d8cf530647cf";
        };
        cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DAVIF_LIBYUV_ENABLED=ON" ];
        patches = [];
      });
}
