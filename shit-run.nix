{ inputs }:
let
  pkgs2505 = import inputs.nixpkgs2505 { };
  pkgs2003 = import inputs.nixpkgs2003 { };

  envScript = ''
    # prevents various error messages
    unset GIO_EXTRA_MODULES

    # This is needed for IME (e.g. iBus, fcitx5) to function correctly on non-CJK locales
    # https://github.com/ValveSoftware/steam-for-linux/issues/781#issuecomment-2004757379
    GTK_IM_MODULE='xim'
  '';

in
self: super: {
  shit-run =
    with super;
    buildFHSEnv {
      name = "shit-run";

      # Steam still needs 32bit and various native games do too
      multiArch = true;

      targetPkgs = with xorg; pkgs: ([
        #    steam
        # License agreement
        #    gnome.zenity

        # Needed for operating system detection until
        # https://github.com/ValveSoftware/steam-for-linux/issues/5909 is resolved
        lsb-release
        # Errors in output without those
        pciutils
        # run.sh wants ldconfig
        glibc.bin
        # Games' dependencies
        xrandr
        which
        # Needed by gdialog, including in the steam-runtime
        #    perl
        # Open URLs
        xdg-utils
        #    iana-etc
        # Steam Play / Proton
        #    python3
        # Steam VR
        procps
        usbutils

        # It tries to execute xdg-user-dir and spams the log with command not founds
        xdg-user-dirs

        # electron based launchers need newer versions of these libraries than what runtime provides

      ]);

      multiPkgs = with xorg; pkgs: ([
        # These are required by steam with proper errors
        libXcomposite
        libXtst
        libXrandr
        libXext
        libX11
        libXfixes
        sqlite
        mod.mesa
        libGL
        libva
        mod.pipewire
        wireplumber
        pulseaudio
        openal

        # steamwebhelper
        harfbuzz
        libthai
        pango

        lsof # friends options won't display "Launch Game" without it
        file # called by steam's setup.sh

        # dependencies for mesa drivers, needed inside pressure-vessel
        mesa.llvmPackages.llvm.lib
        vulkan-loader
        expat
        wayland
        libxcb
        libXdamage
        libxshmfence
        libXxf86vm
        elfutils

        # Without these it silently fails
        libXinerama
        libXcursor
        libXrender
        libXScrnSaver
        libXi
        libSM
        libICE
        pkgs2505.gnome2.GConf
        curlWithGnuTls
        nspr
        nss
        cups
        libcap
        SDL2
        libusb1
        dbus-glib
        gsettings-desktop-schemas
        ffmpeg
        libudev0-shim

        # Verified games requirements
        fontconfig
        freetype
        libXt
        libXmu
        libogg
        libvorbis
        SDL
        SDL2_image
        glew_1_10
        libdrm
        libidn
        tbb
        zlib
        zstd

        # SteamVR
        udev
        dbus

        # Other things from runtime
        glib
        pkgs2505.gtk2
        bzip2
        flac
        freeglut
        libjpeg
        libjpeg8
        libavif
        libwebp
        libjxl
        libpng
        libpng12
        libsamplerate
        libmikmod
        libtheora
        libtiff
        pixman
        speex
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2_ttf
        SDL2_mixer
        sdl3
        sdl3-image
        sdl3-ttf
        pkgs2505.libappindicator-gtk2
        pkgs2505.libdbusmenu-gtk2
        pkgs2505.libindicator-gtk2
        libcaca
        libcanberra
        libgcrypt
        libunwind
        libvpx
        librsvg
        libXft
        libvdpau

        # required by coreutils stuff to run correctly
        # Steam ends up with LD_LIBRARY_PATH=<bunch of runtime stuff>:/usr/lib:<etc>
        # which overrides DT_RUNPATH in our binaries, so it tries to dynload the
        # very old versions of stuff from the runtime.
        # FIXME: how do we even fix this correctly
        attr

        # Not formally in runtime but needed by some games
        at-spi2-atk
        at-spi2-core # CrossCode
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-plugins-base
        json-glib # paradox launcher (Stellaris)
        libdrm
        libxkbcommon # paradox launcher
        libvorbis # Dead Cells
        libxcrypt # Alien Isolation, XCOM 2, Company of Heroes 2
        mono
        ncurses # Crusader Kings III
        openssl
        pkgs2003.openssl_1_0_2
        xkeyboardconfig
        libpciaccess
        libXScrnSaver # Dead Cells
        icu # dotnet runtime, e.g. Stardew Valley

        # screeps dependencies
        gtk3
        zlib
        atk
        cairo
        freetype
        gdk-pixbuf
        fontconfig

        # Prison Architect
        libGLU
        libuuid
        libbsd
        alsa-lib

        # Loop Hero
        # FIXME: Also requires openssl_1_1, which is EOL. Either find an alternative solution, or remove these dependencies (if not needed by other games)
        libidn2
        libpsl
        nghttp2.lib
        rtmpdump
      ]);

      profile = ''
        # Workaround for issue #44254 (Steam cannot connect to friends network)
        # https://github.com/NixOS/nixpkgs/issues/44254
        if [ -z ''${TZ+x} ]; then
          new_TZ="$(readlink -f /etc/localtime | grep -P -o '(?<=/zoneinfo/).*$')"
          if [ $? -eq 0 ]; then
            export TZ="$new_TZ"
          fi
        fi

        # udev event notifications don't work reliably inside containers.
        # SDL2 already tries to automatically detect flatpak and pressure-vessel
        # and falls back to inotify-based discovery [1]. We make SDL2 do the
        # same by telling it explicitly.
        #
        # [1] <https://github.com/libsdl-org/SDL/commit/8e2746cfb6e1f1a1da5088241a1440fd2535e321>
        export SDL_JOYSTICK_DISABLE_UDEV=1
      '';

      runScript = (
        writeShellScript "shit-run" ''
          run="$1"
          if [ "$run" = "" ]; then
            echo "Usage: shit-run command-to-run args..." >&2
            exit 1
          fi
          shift


          set -o allexport # Export the following env vars
          ${envScript}
          exec -- "$run" "$@"
        ''
      );

      privateTmp = true;

      extraPreBwrapCmds = ''
        install -m 1777 -d /tmp/dumps
      '';

      extraBwrapArgs = [
        "--bind-try /tmp/dumps /tmp/dumps"
      ];

      meta = {
        description = "shit-run (steam-run clone)";
      };
    };
}
