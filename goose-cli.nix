{ inputs }:
self: super: {
  goose-cli = with super; rustPlatform.buildRustPackage (finalAttrs: {
    pname = "goose-cli";
    version = "1.60.2";

    src = fetchFromGitHub {
      owner = "aaif-goose";
      repo = "goose";
      tag = "v${finalAttrs.version}";
      hash = "sha256-gXk9tnTp9vfL1/9BEJ7TYBZdemAnoc039pMzabRqxhU=";
    };

    cargoHash = "sha256-vqKRl4qxlHDEqe652BPtfnWvsee/X0rwaFcuY9AoA7Q=";

    cargoBuildFlags = [
      "--bin"
      "goose"
    ];

    nativeBuildInputs = [
      cmake
      pkg-config
      protobuf
      rustPlatform.bindgenHook
      makeWrapper
    ];

    buildInputs = [
      aws-lc
      dbus
      oniguruma
      openssl
      sqlite
      zstd
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ libxcb ];

    env = {
      LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";
    };

    # LLVM 21 cannot select the VPDPBUSD intrinsic because its argument types are incorrect.
    # Fixed by https://github.com/rust-lang/llvm-project/commit/94e2c19f86a699d7a19ff0f4130b696699189c8d.
    postPatch = lib.optionalString (stdenv.hostPlatform.isx86_64) ''
      for f in "$cargoDepsCopy"/source-registry-0/candle-core-*/src/quantized/mod.rs \
               "$cargoDepsCopy"/source-registry-0/candle-core-*/src/quantized/repack.rs; do
        if [ -f "$f" ]; then
          substituteInPlace "$f" \
            --replace-fail \
              '#[cfg(target_arch = "x86_64")]' \
              '#[cfg(any())]' \
            --replace-fail \
              '#[cfg(not(any(target_arch = "aarch64", target_arch = "x86_64")))]' \
              '#[cfg(not(target_arch = "aarch64"))]'
        fi
      done
    '';

    postFixup = ''
      wrapProgram $out/bin/goose \
        --prefix PATH : ${
          lib.makeBinPath (
            [
              bash
              python3
            ]
            ++ lib.optionals stdenv.hostPlatform.isLinux [
              # X11
              xdotool
              wmctrl
              xclip
              xwininfo
              # Wayland
              wtype
              wl-clipboard
            ]
          )
        }
    '';

    # Upstream does not gate releases on this test suite, and keeping it running
    # here means maintaining a long list of per-test skips on every release: the
    # tests race on process-global state, need dbus/keychain, network or loopback
    # access, and several are flaky on aarch64-darwin. Skipping the check phase
    # on all platforms makes tracking upstream releases feasible; the version
    # install check below still exercises the binary.
    doCheck = false;

    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgramArg = "--version";
    doInstallCheck = true;

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Open-source, extensible AI agent that goes beyond code suggestions - install, execute, edit, and test with any LLM";
      homepage = "https://github.com/aaif-goose/goose";
      changelog = "https://github.com/aaif-goose/goose/releases/tag/${finalAttrs.src.tag}";
      mainProgram = "goose";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [
        asiantuntija
        cloudripper
        thardin
        brittonr
        miniharinn
        caniko
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  });
}
