{ inputs }:
self: super: {
  mpd_my =
    with super;
    let
      # nixpkgs mpd's knownFeatures for linux (everything minus platformMask,
      # which is empty on linux). mms was removed in git master so we drop it.
      features = lib.remove "mms" [
        "udisks" "webdav" "cdio_paranoia" "curl" "io_uring"
        "nfs" "smbclient" "bzip2" "zzip" "audiofile" "faad"
        "ffmpeg" "flac" "fluidsynth" "gme" "mad" "mikmod"
        "mpg123" "opus" "vorbis" "vorbisenc" "lame"
        "libsamplerate" "soxr" "alsa" "ao" "jack" "pipewire"
        "pulse" "shout" "qobuz" "libmpdclient" "id3tag"
        "dbus" "expat" "icu" "pcre" "sqlite" "syslog"
        "systemd" "zeroconf" "documentation"
      ];
    in
    (mpd.override {
      inherit features;
      ffmpeg = self.ffmpeg_my;
      stdenv = llvmPackages_22.stdenv;
    }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/MusicPlayerDaemon/MPD";
          ref = "master";
        };
        mesonFlags = oldAttrs.mesonFlags ++ [
          "-Dsoxr=enabled"
          "-Dqobuz=disabled"
          "-Dhtml_manual=false"
          "-Dsystemd=disabled"
        ];
        patches = [ ];
        postPatch = "";
        doCheck = false;
      });
}
