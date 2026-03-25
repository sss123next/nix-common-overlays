{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      version = "2026_03_25";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "879a49308f633be54eaba948a0adb14e17ee561e";
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
