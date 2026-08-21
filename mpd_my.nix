{ inputs }:
self: super: {
  mpd_my =
    let
      #      pkgsmaster = import inputs.nixpkgsmaster { };
    in
    with super;
    (
      #      (pkgsmaster.mpd.override {
      (mpd.override {
        ffmpeg = self.ffmpeg_my;
            stdenv = llvmPackages_22.stdenv;
        #    samba = null;
        #    dbus = null;
        #    libpulseaudio = null;
        #    avahi = null;
      }).overrideAttrs
        (oldAttrs: rec {
          version = "git";
          src = fetchGit {
            url = "https://github.com/MusicPlayerDaemon/MPD";
            ref = "master";
#            rev = "d4e8fa5eded583a710e4a47b3f51ca26a4ad31f1";
          };
          buildInputs = oldAttrs.buildInputs ++ [ soxr ];
          mesonFlags = oldAttrs.mesonFlags ++ [
            "-Dsoxr=enabled"
            "-Dqobuz=disabled"
            "-Dhtml_manual=false"
            "-Dsystemd=disabled"
          ];
          patches = [ ];
          postPatch = "";
          doCheck = false;
        })
    );
}
