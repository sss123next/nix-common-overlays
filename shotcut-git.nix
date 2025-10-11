{ inputs }:
self: super: {
  shotcut-git =
    with super;
    (shotcut.override {
      qt6Packages.mlt = self.mlt_my;
    }).overrideAttrs
      (old: rec {
        version = "00.00.00";
        src = fetchGit {
          url = "https://github.com/mltframework/shotcut";
          ref = "master";
          #              submodules = true;
        };
        buildInputs = old.buildInputs ++ [ qt6Packages.qtwebsockets ];
        patches = [ ];
      });
}
