{ inputs }:
self: super: {
  #        darktable_my = with nixpkgsmaster; with llvmPackages_16; with gnome; with gsettings-desktop-schemas; (enableDebugging  ((darktable.override{
  darktable_my =
    with super;
    with gnome;
    with gsettings-desktop-schemas;
    with llvmPackages;
    (darktable.override {
      stdenv = llvmPackages.stdenv;
      exiv2 = self.exiv2_my;
      libaom = self.libaom_my;
      libavif = self.libavif_my;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/darktable-org/darktable";
          ref = "master";
#                    rev = "cf3e972fb05d433a7764ee661850182ba456e128";
          submodules = true;
          #              allRefs = true;
        };
        #            nativeBuildInputs = old.nativeBuldInputs ++ [
        #cmake ninja llvm
        #clang pkg-config
        #intltool perl desktop-file-utils wrapGAppsHook gsettings-desktop-schemas
        #           ];
        nativeBuildInputs = old.nativeBuildInputs ++ [
          git
          po4a
          bash
        ];
        buildInputs = old.buildInputs ++ [
          self.dav1d
          rav1e
          self.libyuv_my
          openmp
          self.shaderc_my
        ];
        patches = [ ];
        postPatch = lib.concatStringsSep "\n" [
          ''
            pushd tools
            patchShebangs *.py *.sh
            popd
          ''
        ];
      });
}
