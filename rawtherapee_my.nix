{ inputs }:
self: super: {
  rawtherapee_my =
    with super;
    (rawtherapee.override {
      #  exiv2 = self.exiv2_my;
    }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/Beep6581/RawTherapee";
          ref = "dev";
          submodules = true;
        };
        patches = [ ];
        buildInputs = oldAttrs.buildInputs ++ [
          #self.my_exiv2
          self.libraw
        ];
        cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWITH_SYSTEM_LIBRAW=TRUE" ];
      });
}
