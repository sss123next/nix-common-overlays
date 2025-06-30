{ inputs }:
self: super: {
  libva_my =
    with super;
    libva.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/intel/libva";
        ref = "master";
      };
      patches = [ ];
    });
}
