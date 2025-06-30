{ inputs }:
self: super: {
  librewolf_my =
    with super;
    wrapFirefox.override
      {
        #        libpulseaudio = libpressureaudio;
        #        stdenv = super.ccacheStdenv;
        #        ffmpeg = self.ffmpeg_my;
      }
      #  ((nixpkgs2405.librewolf-unwrapped.override{}).overrideAttrs(
      ((librewolf-unwrapped.override { }).overrideAttrs (oldAttrs: rec {
        MOZ_REQUIRE_SIGNING = "";
      }))
      {
        extraPolicies = {
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
          ExtensionSettings = {
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # # Privacy Badger:
            # "jid1-MnnxcxisBPnSXQ@jetpack" = {
            #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            #   installation_mode = "force_installed";
            # };
            "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
              installation_mode = "force_installed";
            };
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };
          };

        };
        # browser.ffmpegSupport = true;
        # browser.alsaSupport = true;
        # browser.pipewireSupport = true;
        # browser.jackSupport = false;
        # browser.smartcardSupport = false;
        # browser.sndioSupport = false;

      };
  firefox_my =
    with super;
    wrapFirefox.override
      {
        #             libpulseaudio = libpressureaudio;
        #stdenv = super.ccacheStdenv;
        #        ffmpeg = self.ffmpeg_my;
        #        libaom = self.libaom_my;
      }
      ((firefox-unwrapped.override { }).overrideAttrs (oldAttrs: rec {
        MOZ_REQUIRE_SIGNING = "";
      }))
      {
        extraPolicies = {
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
          ExtensionSettings = {
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # # Privacy Badger:
            # "jid1-MnnxcxisBPnSXQ@jetpack" = {
            #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            #   installation_mode = "force_installed";
            # };
            "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
              installation_mode = "force_installed";
            };
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
        # browser.ffmpegSupport = true;
        # browser.alsaSupport = true;
        # browser.pipewireSupport = true;
        # browser.jackSupport = false;
        # browser.smartcardSupport = false;
        # browser.sndioSupport = false;

      };
}
