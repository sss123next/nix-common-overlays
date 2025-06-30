{ inputs }:
self: super: {
  libplacebo_my =
    with super;
    (libplacebo.override { shaderc = self.shaderc_my; }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://code.videolan.org/videolan/libplacebo";
        ref = "master";
        #       rev = "ef202bcff8cce0e208e244e453d62dcad4c350ca";
      };
      nativeBuildInputs = old.nativeBuildInputs ++ [ xxHash ];
    });
}
