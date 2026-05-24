{ inputs }:
self: super: {
  awesome-git =
    with super;
    awesome.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/awesomeWM/awesome";
        ref = "master";
      };
      patches = [ ];
    });
}
