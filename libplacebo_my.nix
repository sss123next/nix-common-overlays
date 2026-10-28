{ inputs }:
self: super: {
  libplacebo_my =
    with super;
    (libplacebo.override { shaderc = self.shaderc_my; }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://code.videolan.org/videolan/libplacebo";
        ref = "master";
        rev = "275f7dea27924cdd34ab2e6c20e448b6bc4fab65";
      };
      nativeBuildInputs = old.nativeBuildInputs ++ [ xxHash ];
      patches = [];
    });
}
