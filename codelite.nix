{ inputs }:
self: super: {
  codelite =
    with super;
    with gnome;
    with gsettings-desktop-schemas;
    (llvmPackages_16.stdenv.mkDerivation {
      name = "codelite";
      #          version = "2022-02-22";
      version = "git";
      src = fetchGit {
        url = "https://github.com/eranif/codelite";
        ref = "master";
        rev = "ad88f618a0276cfe2f5a189ba3408ac4c08b908f";
        #            rev = "1393fdee2cc0a5d97b35a4f7db44f6e344a67b6d";
        submodules = true;
      };
      nativeBuildInputs = [
        cmake
        pkg-config
        wrapGAppsHook3
        which # required for cmake script
      ];
      buildInputs = [
        clang_16
        sqlite
        gsettings-desktop-schemas
        (wxGTK32.overrideAttrs (old: rec {
          #                version = "3.1.6";
          version = "git";
          src = fetchGit {
            url = "https://github.com/wxWidgets/wxWidgets";
            ref = "master";
            rev = "9bae94022c6aa8bb2b1b207f0f64bc362e5cd6af";
            submodules = true;
          };
          configureFlags = [
            "--disable-precomp-headers"
            # This is the default option, but be explicit
            "--disable-monolithic"
            "--enable-mediactrl"
            "--with-nanosvg"
            "--with-opengl"
          ];
        }))
        pcre
        gtk3
        lldb
        hunspell
        libssh
        bison
        flex
      ];
      # Make '#include <hb.h>' Just Work.
      # Do clients expect to use '#include <harfbuzz/hb.h>'?
      NIX_CFLAGS_COMPILE = "-I${harfbuzz.dev}/include/harfbuzz";
      cmakeFlags = [
        "-DWITH_SFTP=1"
        "-DENABLE_SFTP=1"
        "-DUSE_CLANG=1"
        "-DCL_PREFIX=${placeholder "out"}"
      ];
      postPatch = ''
        sed 's/option(ENABLE_STATIC "Enable static build" ON)/option(ENABLE_STATIC "Enable static build" OFF)/g' -i ctags/CMakeLists.txt
        sed 's/set(LIBS -static)//g' -i ctags/CMakeLists.txt
      '';
    });
}
