{ inputs }:
self: super: {
  hyprland =
    with super;
    with super.lib;
    (hyprland.override { }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/hyprwm/Hyprland";
        ref = "main";
        #        rev = "5ee35f914f921e5696030698e74fb5566a804768";
        submodules = true;
      };
      buildInputs = old.buildInputs ++ [ glaze ];
      mesonFlags = concatLists [
        (mapAttrsToList mesonEnable {
          "xwayland" = true;
          "systemd" = true;
          "uwsm" = false;
          "hyprpm" = false;
        })
        (mapAttrsToList mesonBool {
          # PCH provides no benefits when building with Nix
          "b_pch" = false;
          "tracy_enable" = false;
        })
      ];
    });
}
