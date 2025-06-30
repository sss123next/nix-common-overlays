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
        #    stdenv = llvmPackages_17.stdenv;
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
            # rev = "bee9565384761634df5859d144fee60cb4208453";
            rev = "287033c361c45b83adf3caf1e4827868561db9a3";
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
