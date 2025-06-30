{ inputs }:
self: super: {
  shotcut-git =
    with super;
    (shotcut.override {
      mlt = self.mlt_my;
    }).overrideAttrs
      (old: rec {
        version = "00.00.00";
        src = fetchGit {
          url = "https://github.com/mltframework/shotcut";
          ref = "master";
          #              submodules = true;
        };
        patches = [ ];
      });
}
