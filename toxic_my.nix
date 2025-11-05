{ inputs }:
self: super: {
  toxic_my = with super;
stdenv.mkDerivation (finalAttrs: {
  pname = "toxic";
  version = "git";
        src = fetchGit {
          url = "https://github.com/Tox/toxic";
          ref = "master";
        };

  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)" ];

  buildInputs = [
        (libtoxcore.overrideAttrs (old: rec {
          version = "git";
          src = fetchGit {
            url = "https://github.com/TokTok/c-toxcore";
            ref = "master";
            submodules = true;
          };
        }))
    libsodium
    ncurses
    curl
    gdk-pixbuf
    libnotify
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isAarch32) [
    openal
    libopus
    libvpx
    freealut
    qrencode
  ];
  nativeBuildInputs = [
    pkg-config
    libconfig
  ];

  meta = {
    description = "Reference CLI for Tox";
    mainProgram = "toxic";
    homepage = "https://github.com/TokTok/toxic";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
});
  }


