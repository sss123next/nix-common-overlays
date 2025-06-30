{ inputs }:
self: super: {
  hyprcursor =
    with super;
    (hyprcursor.override { }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/hyprwm/hyprcursor";
        ref = "main";
        #             rev = "3219b311283803d4dbdacb3c5cc10cf9e9b7c2b5";
        submodules = true;
      };
    });
}
