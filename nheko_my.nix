{ inputs }:
self: super: {
  nheko_my =
    with super;
    with gnome;
    with gsettings-desktop-schemas;
    (nheko.override {
      mtxclient = mtxclient.overrideAttrs (old: rec {
        src = fetchGit {
          url = "https://github.com/Nheko-Reborn/mtxclient";
          ref = "master";
        };
      });
    }).overrideAttrs
      (oldAttrs: rec {
        #                version = "2023-02-15";
        version = "git";
        src = fetchGit {
          url = "https://github.com/Nheko-Reborn/nheko";
          ref = "master";
          #                  rev = "d95d2fcaa9e3b8ab47275d2bf56e5a7ebddd37e7";
        };
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ wrapGAppsHook ];
        buildInputs = oldAttrs.buildInputs ++ [
          gsettings-desktop-schemas
        ];
        patches = [];
      });
}
