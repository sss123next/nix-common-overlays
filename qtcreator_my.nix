{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      version = "2025_09_11";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "d553d0cfcb7913c1b5acf3614d935c5cd82ff30d";
      };
      nativeBuildInputs =
        with qt6Packages;
        old.nativeBuildInputs
        ++ [
          wrapQtAppsHook
          wrapGAppsHook
        ];
      buildInputs = with qt6Packages; old.buildInputs ++ [ gsettings-desktop-schemas ];
    }));
}
