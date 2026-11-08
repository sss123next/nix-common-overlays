{ inputs }:
self: super: {
  flectar-mail =
    with super;
    let
      # Бросаем кость nix-демону: меняем при каждом коммите оверлея.
      dlopenLibs = [
        libxkbcommon
        libGL
        wayland
      ];
    in
    rustPlatform.buildRustPackage {
      pname = "flectar-mail";
      version = "0.1.0-unstable-2026-11-08";

      src = fetchgit {
        url = "https://github.com/flectar/mail";
        rev = "705e65907c9b29881d9982415e89e470c80e4caf";
        sha256 = "sha256-6Hnpfn0AEaMbswOENU4RKzJvH9WzqrbZjVXJanAn4+Q=";
        fetchSubmodules = true;
      };

      cargoHash = "sha256-ILFHYKm4+pQ7OfGw3NY0xXrZaU0+9oCbVqAqGcz0ixI=";

      nativeBuildInputs = [
        pkg-config
        python3
        autoPatchelfHook
        patchelf
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

      # xkbcommon-dl dlopen()s libxkbcommon-x11.so at runtime. autoPatchelfHook
      # resolves DT_NEEDED only.  We must add dlopen'd lib dirs to RPATH
      # *after* autoPatchelfHook re-writes it.  Override fixupPhase to order
      # correctly: run autoPatchelf first via old fixup, then our patchelf.
      fixupPhase = ''
        runHook preFixup
        runHook fixupPhaseExtra  # let standard fixup (strip, autoPatchelf) run
        runHook postFixup

        # autoPatchelfHook may have re-set RPATH; add our dlopen dirs on top.
        rpath="${lib.makeLibraryPath dlopenLibs}"
        existing=$(${patchelf}/bin/patchelf --print-rpath "$out/bin/flectar-mail" 2>/dev/null || true)
        ${patchelf}/bin/patchelf --set-rpath "''${rpath}:''${existing}" "$out/bin/flectar-mail"
      '';

      # xkbcommon-dl dlopen()s libxkbcommon-x11.so — tell fediverse about it.
      # Force rebuild marker.
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
