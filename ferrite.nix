{ inputs }:
self: super: {
  ferrite =
    with super;
    let
      linuxBuildInputs = [
        gtk3
        libxkbcommon
        wayland
        vulkan-loader
        libGL
        libx11
        libxcursor
        libxi
        libxrandr
        libxcb
        oniguruma
        webkitgtk_4_1
      ];

      darwinFrameworks = with darwin.apple_sdk.frameworks; [
        AppKit
        Cocoa
        CoreFoundation
        CoreGraphics
        CoreServices
        Foundation
        Metal
        QuartzCore
      ];
    in
    rustPlatform.buildRustPackage {
      pname = "ferrite";
      version = "0.3.1";

      src = fetchFromGitHub {
        owner = "OlaProeis";
        repo = "Ferrite";
        rev = "0.3.2-experimental";
        hash = "sha256-ZZmS5LwE71WWeLUJ8efIfqaSoTLRGh+B6jQ1MVZ78f8=";
      };

      cargoLock.lockFile = fetchurl {
        url = "https://raw.githubusercontent.com/OlaProeis/Ferrite/0.3.2-experimental/Cargo.lock";
        hash = "sha256-yFmTS9QcWSMuxy8G39MJOC532EhAj1f4W6QMcmgICkY=";
      };

      nativeBuildInputs = [ pkg-config makeWrapper ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook3 ];

      buildInputs = lib.optionals stdenv.hostPlatform.isLinux linuxBuildInputs
        ++ lib.optionals stdenv.hostPlatform.isDarwin darwinFrameworks;

      # xkbcommon-dl, libGL, vulkan-loader dlopen'd winit/eframe — LD_LIBRARY_PATH.
      # wrapGAppsHook3 бежит в preFixup, поэтому наши vars поверх — через postFixup.
      JEMALLOC_OVERRIDE = "";
      LIBGIT2_NO_VENDOR = "0";

      preBuild = ''
        unset JEMALLOC_OVERRIDE
        unset LIBGIT2_NO_VENDOR
      '';

      postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
        wrapProgram $out/bin/ferrite \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath linuxBuildInputs}"
      '';

      doCheck = false;

      meta = with lib; {
        description = "A fast, lightweight text editor for Markdown, JSON, and more";
        homepage = "https://github.com/OlaProeis/Ferrite";
        license = licenses.mit;
        mainProgram = "ferrite";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
}
