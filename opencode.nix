{ inputs }:
self: super: {
  opencode =
    with super;
    let
      node_modules =
        finalAttrs:
        stdenv.mkDerivation {
          pname = "${finalAttrs.pname}-node_modules";
          inherit (finalAttrs) version src;

          __structuredAttrs = true;
          strictDeps = true;

          impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
            "GIT_PROXY_COMMAND"
            "SOCKS_SERVER"
          ];

          nativeBuildInputs = [
            bun
            writableTmpDirAsHomeHook
          ];

          dontConfigure = true;

          buildPhase = ''
            runHook preBuild

            export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
            # Pin a single os/cpu so the fixed-output FOD hash is reproducible and
            # matches nixpkgs' per-system hashes.json (see opencode issue #49063:
            # "node_modules FOD hash is calibrated against one bun version").
            bun install \
              --cpu="${if stdenv.hostPlatform.isAarch64 then "arm64" else "x64"}" \
              --os="${if stdenv.hostPlatform.isLinux then "linux" else "darwin"}" \
              --filter '!./' \
              --filter './packages/cli' \
              --filter './packages/desktop' \
              --filter './packages/app' \
              --frozen-lockfile \
              --ignore-scripts \
              --no-progress

            bun --bun ./nix/scripts/canonicalize-node-modules.ts
            bun --bun ./nix/scripts/normalize-bun-binaries.ts

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            find . -type d -name node_modules -exec cp -R --parents {} $out \;

            # opencode targets only Linux and Darwin (see meta.platforms), so the
            # Windows executables that "bun install" fetches are never executed.
            # Dropping them keeps the output reproducible on hosts whose security
            # endpoint agents scan the store, and removes the vulnerable bundled 7za.exe.
            find $out -type f -name '*.exe' -delete

            runHook postInstall
          '';

          # NOTE: Required else we get errors that our fixed-output derivation references store paths
          dontFixup = true;

          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          # Calibrated against our nixpkgs bun 1.4.x (the official hashes.json keys to a different
          # bun ABI — opencode issue #49063), so values are pinned from local `got:` output, not
          # upstream. x86_64-linux re-pinned for the production branch dep delta; other systems stay
          # placeholders until recalibrated where they can be built — with a stale declared hash
          # Nix silently reuses an existing store path instead of rebuilding (verified 2026-09).
          outputHash = {
            "x86_64-linux"   = "sha256-igkJ2tUpyajZCHAER2+2Yl5Z4R4SiffHF/N9g+tKazg=";
            "aarch64-linux"  = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=";
            "aarch64-darwin" = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=";
            "x86_64-darwin"  = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=";
          }.${stdenv.hostPlatform.system};
        };

      # schema.ts in v2 writes a single file per invocation (argv[2] only), so the
      # config and tui schemas have to be generated separately.
      schema = finalAttrs: ''
        bun --bun ./packages/cli/script/schema.ts "$out/share/config.json" \
          && cp config.json $out/share/config.json \
          && bun --bun ./packages/cli/script/schema.ts "$out/share/tui.json" \
          && cp tui.json $out/share/tui.json
      '';
    in
    stdenv.mkDerivation (finalAttrs: {
      pname = "opencode";
      version = "2.2.7";

      __structuredAttrs = true;
      strictDeps = true;

      src = fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        rev = "94e070db9794829173b571161f06e61c1e892dd4";
#        ref = "production";
        hash = "sha256-TTUyZYWKWB8yowAqhmXOk2AB/I66XixtnJ+EEAsQBYY=";
      };

      # The native-fetch-timeout patch has been upstreamed upstream in this rev (174200d):
      # packages/util/src/effect/app-node-platform.ts now wraps the global HttpClient's fetch natively.
      patches = [
        # Raise the model retry budget from 10 attempts (~84s) to 65535 by default so transient
        # provider failures (e.g. HTTP 500) keep retrying for days instead of failing the step, and
        # lift the timeout-retry cap of 3 to the same budget. Override at runtime with
        # OPENCODE_RETRY_ATTEMPTS / OPENCODE_TIMEOUT_RETRIES. In v2.1.x the schedule moved out of
        # session/runner/retry.ts into core/src/model-retry.ts; rebased there, applies at offset 0.
        ./patches/opencode-retry-attempts.patch
        # Web GUI: stop generation on Ctrl+G only. Bare Escape still closes popovers and
        # cancels queue editing, but no longer aborts a running turn (interaction.ts). Offset 0.
        ./patches/opencode-esc-no-interrupt.patch
        # Add "Allow always (session)" option to permission dialogs. New literal "always_session"
        # in Permission.Reply; when chosen with checkbox "Only for this session" active, rules
        # are saved to session.permissions (row-level, not project-level permission_saved table).
        # Affects: schema, core, CLI-ACP, TUI, web-app. Offset 0 (rebased on 286beb08).
        ./patches/session-scoped-permissions.patch
      ];

      # NOTE (production 8bca532, post-v2.2.5): the old "splitting: true -> false" workaround for the
      # bun code-splitting regression (nixpkgs PR #564101) was removed. With bun 1.4.2 forcing
      # splitting off now yields a bundle that dies at load time with
      # `ReferenceError: RaL is not defined` (the compiled binary cannot even print shell completions,
      # which is what installShellCompletion caught). Upstream's splitting:true builds and runs clean;
      # re-add the substitution only if a future rev reintroduces the regression.
      postPatch =
        # Relax Bun version check to be a warning instead of an error
        ''
          substituteInPlace packages/script/src/index.ts \
            --replace-fail \
            'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
            'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
        ''
        # schema.ts imports prettier solely to pretty-print the generated JSON. Prettier is a root
        # workspace devDependency and our FOD install excludes the root (--filter '!./', like
        # upstream's in-tree nix packaging, which therefore never runs schema.ts), so it cannot be
        # resolved at build time. Stub format() to return its input unchanged instead of adding an
        # extra build input for cosmetics only (bun transpiles without type-checking).
        + ''
          substituteInPlace packages/cli/script/schema.ts \
            --replace-fail 'import { format } from "prettier"' \
                           'const format = (_input: string) => _input'
        '';

      nativeBuildInputs = [
        bun
        nodejs_26
        installShellFiles
        makeBinaryWrapper
        writableTmpDirAsHomeHook
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        darwin.sigtool
      ];

      configurePhase = ''
        runHook preConfigure

        cp -R ${finalAttrs.passthru.node_modules}/. .
        patchShebangs node_modules
        patchShebangs packages/*/node_modules

        runHook postConfigure
      '';

      env.MODELS_DEV_API_JSON = "${models-dev}/dist/_api.json";
      env.OPENCODE_DISABLE_MODELS_FETCH = true;
      env.OPENCODE_VERSION = finalAttrs.version;
      env.OPENCODE_CHANNEL = "prod";
      # v2 bundles more packages into the CLI; give bun's GC room to avoid OOM.
      env.NODE_OPTIONS = "--max-old-space-size=4096";

      buildPhase = ''
        runHook preBuild

        cd ./packages/cli
        bun --bun ./script/build.ts --single --skip-install

        # $out is empty until installPhase, so create the target dir first.
        mkdir -p "$out/share"
        # Generate the config and tui JSON schemas (schema.ts writes one file per call).
        bun --bun ./script/schema.ts config.json
        cp config.json "$out/share/config.json"
        bun --bun ./script/schema.ts tui.json
        cp tui.json "$out/share/tui.json"

        # v2 config.json no longer embeds a models.dev URL ($id is now opencode.ai/v2/cli.json),
        # so the old file:// localization of model-schema.json has nothing to target.

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        # v2 outputs dist/cli-<os>-<arch>/bin/opencode (was dist/opencode-* in 1.x).
        install -Dm755 dist/cli-*/bin/opencode $out/bin/opencode
        # OpenTUI dlopens Wayland for clipboard image support on Linux hosts.
        wrapProgram $out/bin/opencode \
          --prefix PATH : ${
            lib.makeBinPath (
              [ ripgrep ]
              ++ lib.optionals stdenv.hostPlatform.isDarwin [ sysctl ]
            )
          } \
          ${lib.optionalString stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland ]}"} \
        --set OPENCODE_DISABLE_AUTOUPDATE true

        # config.json / tui.json are already in place from buildPhase.
        install -Dm644 ${models-dev.jsonschema} $out/share/model-schema.json
        install -Dm644 ../../services/site/public/v1/docs/theme.json $out/share/theme.json

        runHook postInstall
      '';

      postInstall =
        lib.optionalString stdenv.hostPlatform.isDarwin ''
          codesign --force --sign - $out/bin/.opencode-wrapped
        ''
        + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
          # v2 dropped the `completion` subcommand (it was parsed as the positional
          # `directory` arg) in favour of the global flag `--completions <shell>`.
          # The old form wrote an ENOENT traceback to stdout, so completions silently
          # contained an error message instead of a script.
          installShellCompletion --cmd opencode \
            --bash <($out/bin/opencode --completions bash) \
            --zsh <(SHELL=/bin/zsh $out/bin/opencode --completions zsh)
        '';

      dontStrip = true;

      nativeInstallCheckInputs = [
        versionCheckHook
        writableTmpDirAsHomeHook
      ];
      doInstallCheck = true;
      versionCheckKeepEnvironment = [
        "HOME"
        "OPENCODE_DISABLE_MODELS_FETCH"
      ];
      versionCheckProgramArg = "--version";

      passthru = {
        jsonschema = {
          config = "${finalAttrs.finalPackage}/share/config.json";
          theme = "${finalAttrs.finalPackage}/share/theme.json";
          tui = "${finalAttrs.finalPackage}/share/tui.json";
        };
        node_modules = node_modules finalAttrs;
      };

      meta = {
        description = "AI coding agent built for the terminal";
        homepage = "https://opencode.ai";
        changelog = "https://github.com/anomalyco/opencode/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [
          delafthi
          DuskyElf
          graham33
        ];
        sourceProvenance = with lib.sourceTypes; [ fromSource ];
        platforms = [
          "aarch64-linux"
          "x86_64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        mainProgram = "opencode";
      };
    });
}
