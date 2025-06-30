{ inputs }:
self: super: {
  zim_my =
    with super;
    zim.overrideAttrs (oldAttrs: rec {
      version = "0.76.1";
      src = fetchurl {
        url = "https://zim-wiki.org/downloads/zim-${version}.tar.gz";
        hash = "sha256-ao7dYldQogjxubAJB3vsTSjTgzOYjkoEei1qWUv5EFU=";
      };
    });
}
