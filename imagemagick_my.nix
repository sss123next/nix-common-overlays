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
        pname = "imagemagick-my";
        # main @ 2026-11-05, upstream is at 7.1.2-36
        version = "git";
        src = fetchGit {
          url = "https://github.com/ImageMagick/ImageMagick";
          ref = "main";
          rev = "435cddf43011ca48c328ccf7c6d9e492cc05d442";
        };

        # --with-jxl / --with-fftw come from libjxlSupport / fftwSupport above;
        # zstd, lzma and zip have no configure switches, they are probed via
        # pkg-config, so listing them as build inputs is enough. jbigkit has a
        # switch only in its --without form, keep it explicit for clarity.
        configureFlags = old.configureFlags ++ [ "--with-jbig" ];

        buildInputs = old.buildInputs ++ [
          jbigkit
          libzip
          xz
          zstd
        ];

        patches = [ ];

        # versionCheckHook greps for `version` in `magick --version`, and a git
        # checkout reports 7.1.2-36 there, so the check can only fail.
        doInstallCheck = false;
      });
}
