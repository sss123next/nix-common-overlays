{ inputs }:
self: super: {
  qtcreator_my =
    with super;
    let
      pname = "qtcreator";
      version = "25.0.0-unstable-2026-09-29";

      src = fetchFromGitHub {
        owner = "qt-creator";
        repo = "qt-creator";
        rev = "f1256259f42205009216ae3418340c7518069213";
        hash = "sha256-wp7n1navYx2ws9Oz3CnaQcXLuSwERPW0M0Bx3ewZ04U=";
      };

      # Go modules for cmdbridge (same deps as 20.0.1, vendor hash unchanged)
      goModules = (buildGoModule {
        pname = "gocmdbridge";
        version = "0.0.0";
        inherit src;
        vendorHash = "sha256-PUMQdVlf6evLjzs263SAecIA3aMuMbjIr1xEztiwmro=";
        setSourceRoot = ''
          sourceRoot=$(echo */src/libs/gocmdbridge/server)
        '';
      }).goModules;

      # Qt6 from nixpkgs
      qt6Pkgs = qt6Packages;

    in stdenv.mkDerivation (finalAttrs: {
      inherit pname version src;

      nativeBuildInputs = [
        cmake
        pkg-config
        ninja
        go
        python3
        (qt6Pkgs.qttools.override { withClang = true; })
        qt6Pkgs.wrapQtAppsHook
        wrapGAppsHook3
      ];

      buildInputs = [
        # Qt6
        qt6Pkgs.qtbase
        qt6Pkgs.qtdoc
        qt6Pkgs.qtsvg
        qt6Pkgs.qtquick3d
        qt6Pkgs.qtwebengine
        qt6Pkgs.qtwayland
        qt6Pkgs.qtserialport
        qt6Pkgs.qtshadertools
        qt6Pkgs.qt5compat
        qt6Pkgs.qtdeclarative
        qt6Pkgs.qtquicktimeline
        qt6Pkgs.qtnetworkauth
        # Optional: Qt HttpServer for MCP server SSE transport
        qt6Pkgs.qthttpserver
        # Optional: Qt Positioning for Android/ML features
        qt6Pkgs.qtpositioning

        # LLVM/Clang toolchain for code model
        llvmPackages_21.libclang
        llvmPackages_21.llvm

        # C++ libs
        yaml-cpp
        litehtml
        libsecret
        gumbo
        rustc-demangle
        elfutils

        # perf profiler
        perf

        # GTK/GNOME integration
        gsettings-desktop-schemas
      ];

      outputs = [ "out" "dev" ];

      cmakeFlags = [
        (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "${placeholder "out"}/share")
        (lib.cmakeBool "QT_NO_FIND_QMLSC" true)
        (lib.cmakeBool "WITH_DOCS" true)
        (lib.cmakeBool "BUILD_DEVELOPER_DOCS" true)
        (lib.cmakeBool "BUILD_QBS" false)
        (lib.cmakeBool "QTC_CLANG_BUILDMODE_MATCH" true)
        (lib.cmakeBool "CLANGTOOLING_LINK_CLANG_DYLIB" true)
        (lib.cmakeBool "CMDBRIDGE_BUILD_VENDOR_MODE" true)
        # Enable new features
        (lib.cmakeBool "BUILD_EXECUTABLE_CMDBRIDGE" true)
      ];

      # Vendor mode requires correct modules.txt; go 1.21+ strict checking
      preConfigure = ''
        export GOCACHE=$TMPDIR/go-cache
        export GOPATH="$TMPDIR/go"
        vendor_dir=src/libs/gocmdbridge/server/go/vendor
        chmod -R u+w src/libs/gocmdbridge/server/go 2>/dev/null || true
        rm -rf "$vendor_dir"
        mkdir -p "$vendor_dir"
        cp -r --no-preserve=mode ${goModules}/. "$vendor_dir/"
        # Generate modules.txt matching go.mod exactly (go 1.21+ requirement)
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

      postInstall = ''
        # Install development headers with correct prefix
        cmake . $cmakeFlags -DCMAKE_INSTALL_PREFIX="''${!outputDev}"
        cmake --install . --prefix "''${!outputDev}" --component Devel
      '';

      postFixup = ''
        # Remove prefix from QtC config for 3rd-party plugin paths
        substituteInPlace "''${!outputDev}/lib/cmake/QtCreator/QtCreatorConfig.cmake" \
          --replace "$out/" ""
      '';

      qtWrapperArgs = [
        "--set-default PERFPROFILER_PARSER_FILEPATH ${lib.getBin perf}/bin"
      ];

      meta = {
        description = "Cross-platform IDE tailored to the needs of Qt developers (master branch)";
        longDescription = ''
          Qt Creator is a cross-platform IDE (integrated development environment)
          tailored to the needs of Qt developers. This build tracks the master branch
          and includes the latest features: ACP/AI Copilot integration, MCP server,
          Java/JDWP debugger, QDoc editor, WSL support, HarmonyOS support, and more.
        '';
        homepage = "https://wiki.qt.io/Qt_Creator";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ ];
        platforms = lib.platforms.linux;
        mainProgram = "qtcreator";
      };
    });
}
