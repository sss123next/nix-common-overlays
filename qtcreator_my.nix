{ inputs }:
self: super: {
  qtcreator_my =
    with super;
    let
      src' = fetchFromGitHub {
        owner = "qt-creator";
        repo = "qt-creator";
        rev = "f1256259f42205009216ae3418340c7518069213";
        hash = "sha256-wp7n1navYx2ws9Oz3CnaQcXLuSwERPW0M0Bx3ewZ04U=";
      };
      # Pre-built go modules — same deps as qtcreator 20.0.1
      goModules' = (buildGoModule {
        pname = "gocmdbridge";
        version = "0.0.0";
        src = src';
        vendorHash = "sha256-PUMQdVlf6evLjzs263SAecIA3aMuMbjIr1xEztiwmro=";
        setSourceRoot = ''
          sourceRoot=$(echo */src/libs/gocmdbridge/server)
        '';
      }).goModules;
    in
    qtcreator.overrideAttrs (old: rec {
      version = "25.0.0-unstable-2026-09-29";
      src = src';
      goModules = goModules';
      nativeBuildInputs =
        with qt6Packages;
        old.nativeBuildInputs or []
        ++ [
          wrapQtAppsHook
          wrapGAppsHook3
        ];
      buildInputs = with qt6Packages; old.buildInputs or [] ++ [ gsettings-desktop-schemas ];
      # Vendor mode enabled (inherited). The pre-built vendor from buildGoModule
      # has correct files but go 1.21+ vendor consistency checks are strict about
      # modules.txt matching go.mod exactly. We populate vendor and overwrite
      # modules.txt with the correct content.
      preConfigure = ''
        export GOCACHE=$TMPDIR/go-cache
        export GOPATH="$TMPDIR/go"
        vendor_dir=src/libs/gocmdbridge/server/go/vendor
        # Pre-built vendor files come from /nix/store (read-only); remove
        # any existing dir and re-create with writable copies
        chmod -R u+w src/libs/gocmdbridge/server/go 2>/dev/null || true
        rm -rf "$vendor_dir"
        mkdir -p "$vendor_dir"
        cp -r --no-preserve=mode ${goModules'}/. "$vendor_dir/"
        # Overwrite modules.txt with one that matches go.mod exactly
        cat > "$vendor_dir/modules.txt" << 'MODULESEOF'
# github.com/fsnotify/fsnotify v1.7.0
## explicit; go 1.17
github.com/fsnotify/fsnotify
# github.com/fxamacker/cbor/v2 v2.5.0
## explicit; go 1.12
github.com/fxamacker/cbor/v2
# github.com/x448/float16 v0.8.4
## explicit; go 1.11
github.com/x448/float16
# golang.org/x/sys v0.17.0
## explicit; go 1.18
golang.org/x/sys/unix
golang.org/x/sys/windows
MODULESEOF
      '';
    });
}
