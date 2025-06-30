{ inputs }:
self: super: {
  easyeffects_my =
    with super;
    (
      (easyeffects.override {
        #    ffmpeg = self.ffmpeg_my;
        #    stdenv = llvmPackages_17.stdenv;
        #    samba = null;
        #    dbus = null;
        #    libpulseaudio = null;
        #    avahi = null;
      }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/wwmm/easyeffects";
          ref = "master";
          #          rev = "9471a39faf18733a00be4e020fb522c08ad28b35";
          rev = "6e39ad16cf93a23e93b42361e4a5c964e8aff0f5";
        };
        #              patches = [];
        doCheck = false;
      })
    );
}
