{ inputs }:
self: super: {
  neochat-git =
    with super;
    neochat.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/KDE/neochat/";
        ref = "master";
      };
    });
}
