{ inputs }:
self: super: {
  murmur-git =
    with super;
    murmur.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/mumble-voip/mumble";
        ref = "master";
        submodules = true;
      };
      patches = [ ];
    });
}
