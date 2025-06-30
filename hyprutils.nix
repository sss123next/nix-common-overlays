{ inputs }:
self: super: {
  hyprutils =
    with super;
    (hyprutils.override { }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/hyprwm/hyprutils";
        ref = "main";
#        rev = "2cd5e4fcd5a77f5c7ebc3f6afac4a86336c31281";
      };
    });
}
