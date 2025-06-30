{ inputs }:
self: super: {
  cdrtools =
    with super;
    (cdrtools.override { }).overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://codeberg.org/schilytools/schilytools";
        ref = "master";
      };
    });
}
