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
#          rev = "d3678bd5b8f25846037f00d21aa6a75a3e8f5e87";
                    rev = "d7992582b93ef4e6f9ab2201a1cfbba43055a270";
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
