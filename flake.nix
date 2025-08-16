{
  outputs =
    { self }:
    let
      nixFiles = builtins.filter (f: f != "flake.nix" && builtins.match ".*\\.nix" f != null) (
        builtins.attrNames (builtins.readDir ./.)
      );

      makeOverlay = file: {
        name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
        value =
          inputs:
          (import (./. + "/${file}") {
            inherit inputs;
          });
      };

    in
    {
      overlays = builtins.listToAttrs (map makeOverlay nixFiles);
    };
}
