{ inputs }:
self: super: {
  feh_my =
    with super;
    (feh.override {
      imlib2 = imlib2Full.override {
        heifSupport = true;
        webpSupport = true;
        svgSupport = true;
        jxlSupport = true;
        psSupport = true;
        libheif = self.libheif_my;
      };
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/derf/feh";
          ref = "master";
        };
        doCheck = false;
        patches = [ ];
      });
}
