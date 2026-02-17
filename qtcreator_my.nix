{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      version = "2026_02_17";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "b49eaa52125e7380bc43e7cbd05d2415988c8a6a";
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
