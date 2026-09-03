{ inputs }:
self: super: {
  qtcreator_my =
    with super;
    (qtcreator.overrideAttrs (old: rec {
#      version = "2026_09_03";
#      src = fetchGit {
#        url = "https://github.com/qt-creator/qt-creator";
#        ref = "master";
#        rev = "54089a4022b33d3fbb2f4a6f9fa4fb33038ea493";
#      };
      nativeBuildInputs =
        with qt6Packages;
        old.nativeBuildInputs or []
        ++ [
          wrapQtAppsHook
          wrapGAppsHook3
        ];
        buildInputs = with qt6Packages; old.buildInputs or [] ++ [ gsettings-desktop-schemas ];
    }));
}
