{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      version = "2026_08_03";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "58245a814875e2c641c31df1ab73bbf7d8651338";
      };
      nativeBuildInputs =
        with qt6Packages;
        old.nativeBuildInputs
        ++ [
          wrapQtAppsHook
          wrapGAppsHook3
        ];
        buildInputs = with qt6Packages; old.buildInputs ++ [ gsettings-desktop-schemas ];
        patches = [];
    }));
}
