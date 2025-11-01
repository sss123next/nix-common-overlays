{ inputs }:
self: super: {
  kdenlive_my =
    with super;
    (kdePackages.kdenlive.override {
      mlt = self.mlt_my;
      ffmpeg-full = self.ffmpeg_my;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://invent.kde.org/multimedia/kdenlive";
          ref = "master";
          #submodules = true;
        };
        #nativeBuildInputs = old.nativeBuildInputs ++ [ kdePackages.extra-cmake-modules ];
        nativeBuildInputs = # with qt6Packages;
          #         with kdePackages;
          old.nativeBuildInputs ++ [
            # kdoctools
            #            extra-cmake-modules
            pkg-config
            gitMinimal
          ];
        buildInputs =
          old.buildInputs
          ++
          #          with qt6Packages;
          #          with kdePackages;
          [
            kddockwidgets
            #        ffmpeg_my
            #            wrapQtAppsHook
            # cmake
            # breeze-icons
            #            pkg-config
            # #    breeze-qt5
            # kconfig
            # kcrash
            # kdbusaddons
            # kfilemetadata
            # kguiaddons
            # ki18n
            # kiconthemes
            # #    kinit
            # knotifications
            # knewstuff
            # karchive
            # knotifyconfig
            # kplotting
            # ktextwidgets
            # mediainfo
            # #    phonon-backend-gstreamer
            # qtdeclarative
            # qtmultimedia
            # qtnetworkauth
            # #qtquickcontrols2
            # #qtscript
            # shared-mime-info
            # libv4l
            # ffmpeg-full
            # frei0r
            # rttr
            # purpose
            # kdeclarative
            # wrapGAppsHook3
            #        (mlt.override { ffmpeg = self.ffmpeg_my; })
          ];
        patches = [ ];
      });
}
