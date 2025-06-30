{ inputs }:
self: super: {
  dav1d_my =
    with super;
    dav1d.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://code.videolan.org/videolan/dav1d.git";
        ref = "master";
        rev = "5ea4939a1dde36ebc24fc5a026eeacaa74f366a4";
        #              rev = "aa63a41ccddda86662374d4fb5a1e7fb1c69b881";
      };
      patches = [ ];
    });
}
