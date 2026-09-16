{ inputs }:
self: super: {
  libplacebo_my =
    with super;
    (libplacebo.override { shaderc = self.shaderc_my; }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://code.videolan.org/videolan/libplacebo";
        ref = "master";
        rev = "3330a515d62139259c26239014f286e233bd3a5c";
      };
      nativeBuildInputs = old.nativeBuildInputs ++ [ xxHash ];
      patches = [];
    });
}
