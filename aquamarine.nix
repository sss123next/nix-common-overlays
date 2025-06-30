{ inputs }:
self: super: {
  aquamarine =
    with super;
    (aquamarine.override { }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/hyprwm/aquamarine";
        ref = "main";
        #        rev = "7fe006981fae53e931f513026fc754e322f13145";
      };
      #         patches = old.patches ++ [ "/etc/nixos/patches/aquamarine/bit_depth.patch" ];
      #      patches = [ /home/sss/nix/patches/aquamarine/bit_depth.patch ];
    });
}
