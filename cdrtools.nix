{ inputs }:
self: super: {
  cdrtools =
    with super;
    (cdrtools.override { }).overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://codeberg.org/schilytools/schilytools";
        rev = "e835e64f0d84a614b3c8d619ac646060ea6922a5";
      };
    });
}
