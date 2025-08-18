{ inputs }:
self: super: {
  qtcreator_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (qtcreator.overrideAttrs (old: rec {
      version = "2025_08_18";
      src = fetchGit {
        url = "https://github.com/qt-creator/qt-creator";
        ref = "master";
        rev = "989042943519ebc3e640c2ae7bee06034d3329fa";
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
