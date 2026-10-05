{ inputs }:
self: super: {
  mumble-git =
    with super;
    with gsettings-desktop-schemas;
    mumble.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/mumble-voip/mumble";
        ref = "master";
        rev = "24d3ec646a12230e8da3e7d3d0e50de429c9a039";
        submodules = true;
      };
      nativeBuildInputs = with qt6Packages; [
        cmake
        pkg-config
        python3
        wrapQtAppsHook
        qttools
        wrapGAppsHook3
      ];
      buildInputs = with qt6Packages; [
        avahi-compat
        alsa-lib
        boost
        poco
        protobuf
        qtsvg
        libsndfile
        libopus
        speexdsp
        gsettings-desktop-schemas
        utf8proc
        microsoft-gsl
        nlohmann_json
      ];
      patches = [ ];
      # GCC16 по умолчанию собирает на C23, где `bool` — ключевое слово:
      # overlay_gl/overlay.c не компилируется (`typedef _Bool bool`). Форсим gnu17 для C.
      cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [ "-DCMAKE_C_FLAGS=-std=gnu17" ];
    });
}
