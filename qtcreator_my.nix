{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
       version = "2025_07_18";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "52d04bddd68cea4c7d66b2918977a909708e8e7c";
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
