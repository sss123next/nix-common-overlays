{ inputs }:
self: super:
let
  inherit (super) lib;
in
{
  # libslvs — решатель геометрических ограничений для Design/CAD-таба OrcaSlicer.
  # Сами исходники взяты из SolveSpaceLib (GPLv3), а CMakeLists.txt.in —
  # собственный файл OrcaSlicer (upstream-ний CMakeLists собирает только
  # демо и не имеет install-правил); копируется как ./CMakeLists.txt.
  slvs = super.clangStdenv.mkDerivation (finalAttrs: {
    pname = "slvs";
    version = "3.0-unstable-2018-10-16";

    src = super.fetchFromGitHub {
      owner = "JacobStoren";
      repo = "SolveSpaceLib";
      rev = "4d8704523e4bf212fadf5189f92484244f670fea";
      hash = "sha256-xe6J+cnOUWLo5561CskQlR+3Co8FriCupc8l1lhhocA=";
    };

    nativeBuildInputs = [ super.cmake ];

    postPatch = ''
      cp ${./slvs/CMakeLists.txt} ./CMakeLists.txt
    '';

    meta = {
      description = "Geometric constraint solver library extracted from SolveSpace";
      homepage = "https://github.com/JacobStoren/SolveSpaceLib";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  });
}
