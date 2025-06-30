{ inputs }:
self: super: {
  qtcreatore_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      # version = "2025_06_12";
      version = "2025_06_30";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "b60337dbaace15ac36d7f44f60d17560111a9ae3";
        #rev = "ef4218b51d54457e674e48dafbb4452a06051fe7";
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
