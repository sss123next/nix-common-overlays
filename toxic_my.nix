{ inputs }:
self: super: {
  toxic_my =
    with super;
    (
      (toxic.override {
        libtoxcore = super.libtoxcore.overrideAttrs (old: rec {
          version = "git";
          src = fetchGit {
            url = "https://github.com/TokTok/c-toxcore";
            ref = "master";
            submodules = true;
          };
        });
        #    samba = null;
        #    dbus = null;
        #    libpulseaudio = null;
        #    avahi = null;
        meta = with lib; {};
      }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/Tox/toxic";
          ref = "master";
        };
        meta = with lib; {};
      })
    );
}
