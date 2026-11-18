{ inputs }:
self: super: {
  deepseek-harness =
    with super;
    let
      # node-addon-require-builtin v0.1.9 probes the V8 getter
      # `PrincipalRealm::builtin_module_require` by scanning the ELF's
      # exported symbols (V8 is statically linked but its symbols are
      # re-exported by node).  The scanner does a byte-sequence match on
      # that getter and rejects builds where the compiler emitted any
      # epilogue beyond the mov+ret — notably nixpkgs' default hardening
      # `-fzero-call-used-regs=used-gpr` adds `xor %edi,%edi` before the
      # ret on x86_64, which trips the matcher.
      #
      # Since app-boot >= 0.2.1-rc.2, `requireInternalOrAddon()` tries
      # `createRequire(id)` with `--expose-internals` first and falls back
      # to the addon only when that throws.  Ship with `--expose-internals`
      # and use nixpkgs' own Node — the official-node binary and its
      # patchelf/LD_LIBRARY_PATH workaround are no longer needed.
    in
    stdenv.mkDerivation (finalAttrs: rec {
      pname = "deepseek-harness";
      # Release candidate tags exist; pinned to the most recent one.
      # Node 26 migration: nixpkgs default was nodejs_22 (below engine floor >=24.9.0).
      # rc.3 adds @deepseek-ai/dsh-terminal-panel workspace dep.
      version = "v0.2.2-rc.4-unstable-2026-11-17";

      src = fetchFromGitHub {
        owner = "deepseek-ai";
        repo = "deepseek-harness";
        rev = "refs/tags/dsh-v0.2.2-rc.4";
        hash = "sha256-milWV/D6usfjicaZkOHrF904nLttAiHfMse5i1HP6/o=";
      };

      # packageManager: pnpm@11.28.5 (nixpkgs pnpm_11 lags a bit; tolerated).
      # Ship on nodejs_26 (engines >= 24.9.0) — nixpkgs' default nodejs is
      # nodejs_22 which is below the floor.
      # pnpm >= 11 needs fetcher version 4.
      pnpm = pnpm_11;

      nativeBuildInputs = [
        nodejs_26
        pnpm
        pnpmConfigHook
        makeShellWrapper
        xz
      ];

      buildInputs = [ ];

      dontAutoPatchelf = true;

      # Full workspace install (no --filter): the release build compiles every
      # package (host + client TS aggregates, web frontend, native addons).
      pnpmWorkspaces = [ ];

      pnpmDeps = fetchPnpmDeps {
        inherit pname version src pnpm;
        pnpmWorkspaces = [ ];
        fetcherVersion = 4;
        hash = "sha256-md84fDBaEnqdQxlsTpaGTkGWWH1dLUGwlSp0EJ+aOA4=";
      };

      env.NODE_OPTIONS = "--max-old-space-size=4096";
      # fetchFromGitHub provides no .git; client-build-environment.ts reads this
      # public value instead of spawning `git rev-parse HEAD`, and its dirty
      # probe treats a missing git as "no metadata" (no dirty marker).
      env.DSH_CLIENT_COMMIT_HASH = "3f321d32bfe382212a8ed8785c1d47a5a300aa23";

      # `pnpm run build` (scripts/build.ts) = build:native-system (flock Node-API
      # addon; needs the node headers next to process.execPath) + build:lib (tsc
      # host/client + tsdown into each package's lib/) + build:web (vite).
      # pnpmConfigHook installs with --ignore-scripts, so the root postinstall
      # (lefthook git hooks) and dependency build scripts (esbuild ships its
      # binary as an optional platform package) are skipped by design.
      buildPhase = ''
        runHook preBuild

        pnpm run build

        runHook postBuild
      '';

      # Sometimes the build puts runtime in share/deepseek-harness, sometimes
      # in libexec/dsh; probe both.
      installPhase = ''
        runHook preInstall

        # Determine where the workspace landed — the install layout evolves
        # between versions.  We know the CLI entry is apps/cli/lib/bin.js.
        if [ -d "$PWD/apps/cli" ]; then
          # pnpmConfigHook leaves us in the source dir; copy manually.
          mkdir -p $out/libexec/dsh
          tar --exclude=./node_modules --exclude=./.git -cf - . \
            | tar -xf - -C $out/libexec/dsh

          mkdir -p $out/libexec/dsh/node_modules
          tar -C node_modules -cf - . \
            | tar -xf - -C $out/libexec/dsh/node_modules

          # Absolute symlinks → fail (they dangle cross-store).
          abs=$(
            find $out/libexec/dsh -type l | while read -r l; do
              t=$(readlink "$l")
              case "$t" in /*) echo "$l -> $t";; esac
            done
          )
          if [ -n "$abs" ]; then
            echo "ERROR: absolute symlinks in output:" >&2
            echo "$abs" >&2
            exit 1
          fi
          dangling=$(find $out/libexec/dsh -xtype l)
          if [ -n "$dangling" ]; then
            echo "ERROR: dangling symlinks in output:" >&2
            echo "$dangling" >&2
            exit 1
          fi
        else
          echo "ERROR: no apps/cli in build directory" >&2
          ls -la . >&2
          exit 1
        fi

        # Launcher using nixpkgs' node with --expose-internals.
        mkdir -p $out/bin
        makeWrapper ${lib.getExe nodejs_26} $out/bin/dsh \
          --add-flags "--expose-internals" \
          --add-flags "$out/libexec/dsh/apps/cli/lib/bin.js"

        runHook postInstall
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        v=$($out/bin/dsh --version)
        echo "dsh --version => $v"
        case "$v" in
          0.2.2-rc.*) ;;
          0.2.2-alpha*) ;;
          0.2.1-rc.*) ;;
          0.2.1-alpha*) ;;
          *) echo "ERROR: unexpected dsh version: $v" >&2; exit 1 ;;
        esac
        $out/bin/dsh --help > /dev/null

        runHook postInstallCheck
      '';

      meta = {
        description = "AI coding harness where everything is a plugin";
        homepage = "https://deepseek.com/harness";
        changelog = "https://github.com/deepseek-ai/deepseek-harness/releases";
        license = lib.licenses.mit;
        mainProgram = "dsh";
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
      };
    });
}
