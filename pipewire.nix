{ inputs }:
self: super: {
  pipewire =
    with super;
    (pipewire.override {
      zeroconfSupport = false;
      ffadoSupport = false;
      vulkanSupport = false;
      x11Support = false;
    }).overrideAttrs
      (old: rec {
        version = "git";
        name = "pipewire";
        src = fetchGit {
          url = "https://gitlab.freedesktop.org/pipewire/pipewire";
          ref = "master";
#          rev = "2771c435fdc9b751c00c57dc48d83069e3fe7396";
                              rev = "4f3a2d723b617e278efc82835baa93f65d756fa4";
        };

        postUnpack = ''
          patchShebangs source/doc/*.py 
          patchShebangs source/doc/input-filter-h.sh 
        '';

        postInstall = ''
          moveToOutput "bin/pw-jack" "$jack"
        '';
        buildInputs = old.buildInputs ++ [
          libapparmor
          libebur128
        ];
        mesonFlags = [
          (lib.mesonEnable "docs" true)
          (lib.mesonOption "udevrulesdir" "lib/udev/rules.d")
          (lib.mesonEnable "installed_tests" true)
          (lib.mesonOption "installed_test_prefix" (placeholder "installedTests"))
          (lib.mesonOption "libjack-path" "${placeholder "jack"}/lib")
          (lib.mesonEnable "pipewire-jack" true)
          (lib.mesonEnable "jack" true)
          (lib.mesonEnable "libffado" false)
          (lib.mesonEnable "roc" true)
          (lib.mesonEnable "libpulse" true)
          (lib.mesonEnable "avahi" false)
          (lib.mesonEnable "gstreamer" true)
          (lib.mesonEnable "gstreamer-device-provider" true)
          (lib.mesonEnable "systemd" true)
          (lib.mesonEnable "systemd-system-service" true)
          (lib.mesonEnable "udev" false)
          (lib.mesonEnable "ffmpeg" true)
          (lib.mesonEnable "pw-cat-ffmpeg" true)
          (lib.mesonEnable "bluez5" false)
          (lib.mesonEnable "bluez5-backend-hsp-native" false)
          (lib.mesonEnable "bluez5-backend-hfp-native" false)
          (lib.mesonEnable "bluez5-backend-native-mm" false)
          (lib.mesonEnable "bluez5-backend-ofono" false)
          (lib.mesonEnable "bluez5-backend-hsphfpd" false)
          # source code is not easily obtainable
          (lib.mesonEnable "bluez5-codec-lc3plus" false)
          (lib.mesonEnable "bluez5-codec-lc3" false)
          (lib.mesonEnable "bluez5-codec-ldac" false)
          (lib.mesonEnable "opus" true)
          (lib.mesonOption "sysconfdir" "/etc")
          (lib.mesonEnable "raop" false)
          (lib.mesonOption "session-managers" "")
          (lib.mesonEnable "vulkan" false)
          (lib.mesonEnable "x11" false)
          (lib.mesonEnable "x11-xfixes" false)
          (lib.mesonEnable "libcanberra" false)
          (lib.mesonEnable "libmysofa" true)
          (lib.mesonEnable "sdl2" false) # required only to build examples, causes dependency loop
          (lib.mesonBool "rlimits-install" false) # installs to /etc, we won't use this anyway
          (lib.mesonEnable "compress-offload" true)
          (lib.mesonEnable "man" true)
          (lib.mesonEnable "snap" false) # we don't currently have a working snapd
          (lib.mesonEnable "libcamera" false)
        ];
      });
}
