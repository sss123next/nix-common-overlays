{ inputs }:
self: super: {
  flectar-mail =
    with super;
    let
      dlopenLibs = [
        libxkbcommon
        libGL
        wayland
        fontconfig
      ];
    in
    rustPlatform.buildRustPackage {
      pname = "flectar-mail";
      version = "0.1.0-unstable-2026-11-09";

      src = fetchgit {
        url = "https://github.com/flectar/mail";
        rev = "705e65907c9b29881d9982415e89e470c80e4caf";
        sha256 = "sha256-6Hnpfn0AEaMbswOENU4RKzJvH9WzqrbZjVXJanAn4+Q=";
        fetchSubmodules = true;
      };

      cargoHash = "sha256-6W2+rvCcY7GyCJa36Ld0mN3j/+dSS/SfaTwG0hxpdaw=";

      nativeBuildInputs = [
        pkg-config
        python3
        makeWrapper
      ];

      buildInputs = [
        fontconfig
        freetype
        expat
        zlib
        openssl
        dbus
        libGL
        libx11
        libxcb
        libxcursor
        libxi
        libxrandr
        libxkbcommon
        wayland
        udev
        stdenv.cc.cc.lib
      ];

      # Cargo.toml already has strip = "symbols" in [profile.release];
      dontStrip = true;

      doCheck = false;

      # xkbcommon-dl dlopen()s libxkbcommon-x11.so at runtime. Following
      # ferrite.nix pattern: wrapProgram with LD_LIBRARY_PATH for dlopen'd libs.
      postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
        wrapProgram $out/bin/flectar-mail \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath dlopenLibs}"
      '';

      meta = with lib; {
        description = "A native email client built with Rust, Slint, and Blitz";
        longDescription = ''
          Flectar Mail is a native, lightweight email client with calendar and contacts.
          Minimal memory usage (~20 MB private), no embedded WebView.
          Supports IMAP, JMAP, SMTP, OpenPGP/MIME. Desktop Linux, Windows, macOS, Android, iOS.
        '';
        homepage = "https://flectar.com";
        license = licenses.agpl3Only;
        mainProgram = "flectar-mail";
        platforms = platforms.linux;
        maintainers = [];
      };
    };
}
