{ inputs }:
self: super: {
  keepassxc =
    with super;
    keepassxc.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/keepassxreboot/keepassxc";
        ref = "develop";
        #              rev = "0207e0fe9f688dfa3c80117f9002031eff68e624";
      };
      buildInputs = oldAttrs.buildInputs ++ [ keyutils ];
      patches = [ ];
    });
}
