{ inputs }:
self: super: {
  rawtherapee_my =
    with super;
    (rawtherapee.override { 
    #  exiv2 = self.exiv2_my;
    }).overrideAttrs (oldAttrs: rec {
      #      version = "2023-03-20";
      version = "git";
      src = fetchGit {
        url = "https://github.com/Beep6581/RawTherapee";
        ref = "dev";
        # owner = "Beep6581";
        # repo = "RawTherapee";
        # rev = "351c9d821219b1a5d4b57f900318e590c581f44e";
        # sha256 = "sha256-exmRVTvy1G+6oyg9pmIdDTJfwHnn+x9MrUKxhM6beFQ=";
      };
      patches = [ ];
      buildInputs = oldAttrs.buildInputs ++ [
        #self.my_exiv2
        self.libraw
      ];
      cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWITH_SYSTEM_LIBRAW=TRUE" ];
    });
}
