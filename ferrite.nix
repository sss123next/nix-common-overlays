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
      version = "0.3.0";

      src = fetchFromGitHub {
        owner = "OlaProeis";
        repo = "Ferrite";
        rev = "master";
        hash = "sha256-en/m1WPzTElEeDE/WcBi6D6cHOpqZ2ZmgnR15RrD/M4=";
      };

      cargoLock.lockFile = ./ferrite/Cargo.lock;

      nativeBuildInputs = [ pkg-config makeWrapper ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook3 ];

      buildInputs = lib.optionals stdenv.hostPlatform.isLinux linuxBuildInputs
        ++ lib.optionals stdenv.hostPlatform.isDarwin darwinFrameworks;

      # xkbcommon-dl, libGL, vulkan-loader dlopen'd winit/eframe — LD_LIBRARY_PATH.
      # wrapGAppsHook3 бежит в preFixup, поэтому наши vars поверх — через postFixup.
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
