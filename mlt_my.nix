{ inputs }:
self: super: {
  mlt_my =
    with super;
    (mlt.override {
      #            stdenv = llvmPackages_16.stdenv;
      #      ffmpeg = self.ffmpeg_my;
      #      opencv4 = (opencv4.override{enableFfmpeg = false;}).overrideAttrs (old: rec {
      #      }
      #        );
      enablePython = true;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/mltframework/mlt";
          ref = "master";
        };
        buildInputs = with qt6Packages; old.buildInputs ++ [ gdk-pixbuf libebur128 qtbase qtsvg ];
        nativeBuildInputs = with qt6Packages; old.nativeBuildInputs ++ [ wrapQtAppsNoGuiHook ];
      });
}
