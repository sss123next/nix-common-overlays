{ inputs }:
self: super: {

  retroshare_my =
    with super;
    (
      (retroshare.override {
        sqlcipher = null;
      }).overrideAttrs
      (oldAttrs: rec {
        #            version = "2023-03-10";
        version = "git";
        src = fetchGit {
          #              url = "https://github.com/RetroShare/RetroShare";
          url = "/home/sss/git/retroshare/RetroShare";
          ref = "fucked_submodules";
          #              rev = "e60fead024158d5d746c090bad2abb2e4053a370";
          #              sha256 = lib.fakeSha256;
          submodules = true;
        };
        #buildInputs = oldAttrs.buildInputs ++ [ libressl ];
        NIX_CFLAGS_COMPILE = "-fpermissive";
        NIX_CXXFLAGS_COMPILE = "-fpermissive";
        qmakeFlags = [
          "RS_UPNP_LIB=miniupnpc"
          "RS_MAJOR_VERSION=0"
          "RS_MINOR_VERSION=6"
          "RS_MINI_VERSION=x"
          "RS_EXTRA_VERSION="
          "CONFIG+=no_sqlcipher"
          "CONFIG+=no_retroshare_plugins"
        ];
        patches = [ ];
        #          patches = [ "/home/sss/git/nix/nixpkgs-patches/retroshare-submodules-fix.patch" ];
        postPatch = ''
          sed 's/''${AR}/ar/g' -i supportlibs/libsam3/Makefile
        '';
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ git ];
      })
    );
}
