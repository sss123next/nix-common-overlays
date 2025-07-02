{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
       version = "2025_07_02";
#      version = "2025_06_30";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
#        rev = "b60337dbaace15ac36d7f44f60d17560111a9ae3";
        rev = "8c45aff0707b739ec0bbd783bf224092b66ec6b1";
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
