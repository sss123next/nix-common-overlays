{ inputs }:
self: super: {
  picard_my =
    with super;
    with python3Packages;
    with qt6;
    with lib;
    (
      (picard.override {
      }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/metabrainz/picard";
          ref = "master";
          submodules = true;
        };
        doCheck = false;
        doInstallCheck = false;
        installCheckTarget = "";
        installCheckFlags = [ ];
        preInstallCheck = "";

        nativeBuildInputs = [
          gettext
          qt6.wrapQtAppsHook
        ];

        buildInputs = [
          qt6.qtbase
          qt6.qtwayland
        ];

        propagatedBuildInputs = [
          #    chromaprint
          discid
          fasteners
          markdown
          mutagen
          pyjwt
          pyqt6
          python-dateutil
          pyyaml
        ];
      })
    );
}
