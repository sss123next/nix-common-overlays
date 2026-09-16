{ inputs }:
self: super: {
  libva_my =
    with super;
    libva.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/intel/libva";
        ref = "master";
        rev = "6b07f7100512817f736967e899b8c26313c20623";
      };
      patches = [ ];
    });
}
