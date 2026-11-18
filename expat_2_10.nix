{ inputs }:
self: super:
let
  inherit (super) lib;
in
{
  # expat 2.10.0 (2026-11-02) — в пиннованном nixpkgs пока только 2.9.0.
  # Нужен OrcaSlicer >= 3838002: upstream (PR #17290) поднял
  # find_package(EXPAT 2.10.0 REQUIRED) после CVE-2026-115506
  # (billion/parameter-laughs вариации через crafted AMF) и трёх других
  # CVE-фиксов 2.10.0. Рецепт — упрощённый nixpkgs'овский: единый output
  # (включает include/, lib/, bin/) вместо разделения out/dev.
  expat_2_10 = super.stdenv.mkDerivation (finalAttrs: {
    pname = "expat";
    version = "2.10.0";

    src = super.fetchurl {
      url = "https://github.com/libexpat/libexpat/releases/download/R_2_10_0/expat-2.10.0.tar.xz";
      hash = "sha256-xiS6KZj8Zd8RY6SWQf8/mrcxOLEWQdkshr7g+wGxvH8=";
    };

    strictDeps = true;
    nativeBuildInputs = [ super.updateAutotoolsGnuConfigScriptsHook ];

    # stdenv по умолчанию передаёт --disable-static; нужен libexpat.a
    # (Orca линкует expat статически, см. EXPAT_LIBRARY в orca-slicer-git.nix).
    configureFlags = [ "--enable-static" ];

    separateDebugInfo = false;
    hardeningEnable = [ "pic" ];

    doCheck = false; # тестовый набор expat тащит лишние инструменты

    postFixup = ''
      # CMake-конфиг вычисляет путь к lib из префикса импорта; при едином
      # output это $out, но на всякий случай фиксируем (nixpkgs делает то же).
      substituteInPlace $out/lib/cmake/expat-${finalAttrs.version}/expat-noconfig.cmake \
        --replace "$"'{_IMPORT_PREFIX}' $out
    '';

    meta = {
      changelog = "https://github.com/libexpat/libexpat/blob/R_2_10_0/expat/Changes";
      homepage = "https://libexpat.github.io/";
      description = "Stream-oriented XML parser library written in C (2.10.0, CVE fixes backport for pinned nixpkgs)";
      mainProgram = "xmlwf";
      platforms = lib.platforms.all;
      license = lib.licenses.mit;
    };
  });
}
