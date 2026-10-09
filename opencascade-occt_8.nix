{ inputs }:
self: super:
let
  inherit (super) lib stdenv;
in
{
  # OCCT 8.0.1 — версия, закреплённая в deps/OCCT OrcaSlicer master
  # (в nixpkgs есть только 7.9.3: код CAD-таба написан под OCCT >= 8,
  # где Standard_Failure наследует std::exception и имеет what()).
  # Выражение — копия pkgs/by-name/op/opencascade-occt/package.nix.
  opencascade-occt_8 = stdenv.mkDerivation (finalAttrs: {
    pname = "opencascade-occt";
    version = "8.0.1";

    src = super.fetchFromGitHub {
      owner = "Open-Cascade-SAS";
      repo = "OCCT";
      tag = "V${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
      hash = "sha256-QgSfrWc6qxbiHBapyGa9+ixRi/dOXqMox8U2f+tCH8o=";
    };

    # Закреплённый фикс из deps/OCCT OrcaSlicer: pcurve шовного ребра.
    # Удалять, когда фикс войдёт в релиз OCCT (см. deps/OCCT/OCCT.cmake).
    patches = [ ./opencascade-occt_8/brepmesh-seam-pcurve.patch ];

    nativeBuildInputs = [
      super.cmake
      super.ninja
    ];

    buildInputs = [
      super.tcl
      super.tk
      super.libGL
      super.libGLU
      super.libxext
      super.libxmu
      super.libxi
      super.rapidjson
    ];

    env.NIX_CFLAGS_COMPILE = "-fpermissive";

    cmakeFlags = [
      (lib.cmakeBool "USE_RAPIDJSON" true)
      # Enable exception handling for release builds.
      (lib.cmakeBool "BUILD_RELEASE_DISABLE_EXCEPTIONS" false)
      # cmake 4 compatibility
      (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
      # OCCT по умолчанию тянет 3rd-party (freeimage/tbb/...); в nixpkgs-выражении
      # они просто не находятся и отключаются, здесь — то же самое.
    ];

    meta = {
      description = "Open CASCADE Technology, libraries for 3D modeling and numerical simulation";
      homepage = "https://www.opencascade.org/";
      license = lib.licenses.lgpl21; # essentially...
      # plus the OCCT_LGPL_EXCEPTION.txt
      maintainers = [ ];
      platforms = lib.platforms.linux;
    };
  });
}
