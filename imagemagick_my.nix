{ inputs }:
self: super: {
  imagemagick_my =
    with super;
    (imagemagick.override {
      libjxlSupport = true;
      ghostscriptSupport = true;
      djvulibreSupport = true;
      libheif = self.libheif_my;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/ImageMagick/ImageMagick";
          ref = "main";
          rev = "305e383c8ac7b30bc2ee96ab8c43ec96217ec2a9";
        };
        configureFlags = old.configureFlags ++ [
          "--with-fftw"
          "--with-jbig"
          "--with-jxl"
        ];
        buildInputs = old.buildInputs ++ [
          fftw
          jbigkit
          libjxl
        ];
        patches = [ ];
        #        doCheck = false;
      });
}
