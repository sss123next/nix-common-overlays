{ inputs }:
self: super: {
  digikam_my =
    with super;
    (digikam.override {
      exiv2 = self.exiv2_my;
      #    ffmpeg = ffmpeg_4-full;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://invent.kde.org/graphics/digikam";
          ref = "master";
          rev = "d857b6e333d6387e3a19d2d553aaa506034f2208";
          #          rev = "30fc3b0daf7b64c4a0968cb4b91896e9d5bb3bfc";
        };
        buildInputs =
          with qt6Packages;
          with kdePackages;
          old.buildInputs
          ++ [
            qtnetworkauth
            self.libheif_my
            self.libavif_my
            (kimageformats.overrideAttrs (old: rec {
              buildInputs = old.buildInputs ++ [
                self.libaom_my
                self.dav1d_my
                rav1e
              ];
            }))
          ];
        cmakeFlags = [
          (lib.cmakeBool "BUILD_WITH_QT6" true)
          (lib.cmakeBool "ENABLE_KFILEMETADATASUPPORT" true)
          (lib.cmakeBool "ENABLE_MEDIAPLAYER" false)
          (lib.cmakeBool "ENABLE_APPSTYLES" true)
        ];
        patches = [ ];
      });
}
