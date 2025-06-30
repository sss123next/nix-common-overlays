{ inputs }:
self: super: {
  htop =
    with super;
    htop.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/htop-dev/htop";
        ref = "main";
        rev = "076b913c7f876ba0489b9751043eeb61aa34680f";
      };
      #      buildInputs = oldAttrs.buildInputs ++ [ libnl ];
    });
}
