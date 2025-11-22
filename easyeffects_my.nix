{ inputs }:
self: super: {
  easyeffects_my =
    with super;
    (
      (easyeffects.override {
        #    ffmpeg = self.ffmpeg_my;
      }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/wwmm/easyeffects";
          ref = "master";
        };
                      patches = [];
        doCheck = false;
      })
    );
}
