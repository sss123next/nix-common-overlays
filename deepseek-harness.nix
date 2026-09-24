{ inputs }:
self: super: {
  deepseek-harness =
    with super;
    stdenv.mkDerivation (finalAttrs: rec {
      pname = "deepseek-harness";
      # No stable tags exist yet (all releases are alpha/rc); pinned to the last
      # master commit instead, upstream version embedded by the build is 0.1.7-rc.1.
      version = "0.1.7-rc.1-unstable-2026-09-23";

      src = fetchFromGitHub {
        owner = "deepseek-ai";
        repo = "deepseek-harness";
        rev = "46a7f68b0922371ce7144b668b90e377d8e799f4";
        # Recursive hash of the unpacked tree (fetchFromGitHub semantics).
        hash = "sha256-jMeqaZciPJJtZ4n/pxKZ/VkCpB+F8NpolQxv7VSki6U=";
      };

      # packageManager: pnpm@11.7.0; pnpm >= 11 needs fetcher version 4.
      pnpm = pnpm_11;

      nativeBuildInputs = [
        nodejs
        pnpm
        pnpmConfigHook
        makeBinaryWrapper
      ];

      # Full workspace install (no --filter): the release build compiles every
      # package (host + client TS aggregates, web frontend, native addons).
      pnpmWorkspaces = [ ];

      pnpmDeps = fetchPnpmDeps {
        inherit pname version src pnpm;
        pnpmWorkspaces = [ ];
        fetcherVersion = 4;
        # FOD hash of the materialized store; pinned from the stub-hash build's
        # `got:` output.
        hash = "sha256-nGuMPIaG8HcC0g1uZmDcalWzZO2hPuSRHSN6A5fJ+n0=";
      };

      env.NODE_OPTIONS = "--max-old-space-size=4096";
      # fetchFromGitHub provides no .git; client-build-environment.ts reads this
      # public value instead of spawning `git rev-parse HEAD`, and its dirty
      # probe treats a missing git as "no metadata" (no dirty marker).
      env.DSH_CLIENT_COMMIT_HASH = "46a7f68b0922371ce7144b668b90e377d8e799f4";

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

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/deepseek-harness

        # The whole workspace: the `dsh` bin resolves its @deepseek-ai/* deps via
        # workspace links into packages/*, and `dsh web` serves the built web
        # artifacts, so source packages with their lib/ output must stay in place.
        tar --exclude=./node_modules --exclude=./.git -cf - . \
          | tar -xf - -C $out/share/deepseek-harness

        # pnpm's workspace graph has symlink cycles (cordis and
        # cordis-plugin-include link into each other), so dereferencing would
        # recurse forever ("File name too long"). Keep the links as-is: the
        # layout above is copied verbatim, so relative targets stay valid.
        mkdir -p $out/share/deepseek-harness/node_modules
        tar -C node_modules -cf - . \
          | tar -xf - -C $out/share/deepseek-harness/node_modules

        # Absolute links would only point back into /build/source and dangle in
        # the store; fail loudly instead of shipping a broken tree.
        abs=$(
          find $out/share/deepseek-harness -type l | while read -r l; do
            t=$(readlink "$l")
            case "$t" in /*) echo "$l -> $t";; esac
          done
        )
        if [ -n "$abs" ]; then
          echo "ERROR: absolute symlinks in output:" >&2
          echo "$abs" >&2
          exit 1
        fi
        dangling=$(find $out/share/deepseek-harness -xtype l)
        if [ -n "$dangling" ]; then
          echo "ERROR: dangling symlinks in output:" >&2
          echo "$dangling" >&2
          exit 1
        fi

        # The launcher entry (apps/cli) is a plain ESM script whose entry guard
        # is `import.meta.main` — needs Node >= 22.19/24 (see upstream engines;
        # older nodes silently exit 0 without printing anything).
        mkdir -p $out/bin
        makeWrapper ${nodejs}/bin/node $out/bin/dsh \
          --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
          --add-flags "$out/share/deepseek-harness/apps/cli/lib/bin.js"

        runHook postInstall
      '';

      # The CLI reports the upstream package.json version (0.1.7-rc.1), not the
      # nix -unstable- suffix, so no versionCheckHook; check the entry point and
      # the version prefix manually instead.
      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        v=$($out/bin/dsh --version)
        echo "dsh --version => $v"
        case "$v" in
          0.1.7-rc.1*) ;;
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
