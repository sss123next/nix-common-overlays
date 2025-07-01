{
  outputs = { self }:
    let
      nixFiles = builtins.filter
        (f: f != "flake.nix" && builtins.match ".*\\.nix" f != null)
        (builtins.attrNames (builtins.readDir ./.));

      # Исправленная функция создания overlay
      makeOverlay = file: {
        name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
        value = inputs: (import (./. + "/${file}") {
#          inherit inputs final prev;
          inherit inputs;
        });
      };

    in {
      overlays = builtins.listToAttrs (map makeOverlay nixFiles);
#      allOverlays = builtins.attrValues overlaysSet;
    };
}

