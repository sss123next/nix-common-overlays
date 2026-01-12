{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      version = "2026_01_12";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "e1210471c3c7773128b4cfea85b8029ce0b662a3";
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
