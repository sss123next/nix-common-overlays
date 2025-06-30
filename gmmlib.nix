{ inputs }:
self: super: {
  intel-gmmlib =
    with super;
    intel-gmmlib.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/intel/gmmlib";
        ref = "master";
        #           rev = "dcc4b85ea3728c848b62fbb164c00f43b519b6fb";
      };
    });
}
