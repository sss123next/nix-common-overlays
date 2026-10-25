{ inputs }:
self: super: {
  deepseek-harness =
    with super;
    let
      # The boot hard-requires node-addon-require-builtin, whose prebuilt .node
      # scans the running node binary for a V8 "x64 sysv getter" accessor and
      # fails with Unsupported/no-getter on nixpkgs' node build (different
      # toolchain/codegen; verified 2026-09 with the same v24.20.0: nixpkgs
      # FAIL, official nodejs.org binary OK). Ship the official binary and run
      # `dsh` with it; nixpkgs node still drives the pnpm/tsc/vite build.
      officialNodeVersion = "24.20.0";
      officialNodeDist = {
        "x86_64-linux" = {
          os = "linux";
          arch = "x64";
          hash = "sha256-LywNoWIxjw3kdmVBDHyMLtPTbI8xBd5LvGEXbHCny/I=";
        };
        "aarch64-linux" = {
          os = "linux";
          arch = "arm64";
          hash = "sha256-X03athDBqyAWs8Inzr2/bZSVFhSH5HOce5AJBZX0Zfc=";
        };
        "x86_64-darwin" = {
          os = "darwin";
          arch = "x64";
          hash = "sha256-JvwwiRAEYD0JTu0R3l780Du9LvvDXBd/xyZI1dencBs=";
        };
        "aarch64-darwin" = {
          os = "darwin";
          arch = "arm64";
          hash = "sha256-t793BwcLlQuh7F8a87tt4PKxlixQM5c9lAaKsCHvMBQ=";
        };
      }.${stdenv.hostPlatform.system};

      officialNode = fetchurl {
        url = "https://nodejs.org/dist/v${officialNodeVersion}/node-v${officialNodeVersion}-${officialNodeDist.os}-${officialNodeDist.arch}.tar.xz";
        hash = officialNodeDist.hash;
      };

      # RPATH в этот бинарь писать нельзя: patchelf 0.19.x при добавлении DT_RUNPATH
      # переписывает заголовки так, что node умирает с SIGSEGV ещё до main (замерено на
      # v24.20.0: 0.15.0 interp+rpath — живой; 0.19.2 только interp — живой; 0.19.2
      # interp+rpath — exit 139, и даже через ld.so напрямую не оживает). Поэтому
      # ставим лишь интерпретатор, а libstdc++/glibc добираем через LD_LIBRARY_PATH:
      # настоящий бинарь уезжает в libexec, на его месте — обёртка (её же видит PATH
      # детей и «#!/usr/bin/env node» у npm/npx из этого дерева).
      officialNodeFix = lib.optionalString stdenv.hostPlatform.isLinux ''
        mkdir -p $out/lib/official-node/libexec
        mv $out/lib/official-node/bin/node $out/lib/official-node/libexec/node-real
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
          $out/lib/official-node/libexec/node-real
        makeWrapper $out/lib/official-node/libexec/node-real $out/lib/official-node/bin/node \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib glibc ]}"
      '';
    in
    stdenv.mkDerivation (finalAttrs: rec {
      pname = "deepseek-harness";
      # No stable tags exist yet (all releases are alpha/rc); pinned to the last
      # master commit instead, upstream version embedded by the build is 0.2.1-alpha.3.
      version = "0.2.1-rc.2-unstable-2026-10-17";

      src = fetchFromGitHub {
        owner = "deepseek-ai";
        repo = "deepseek-harness";
        rev = "687f282e8625c6b8d11ff58211a90524be2e4317";
        hash = "sha256-WcPs3q4NFTRnH2y1Rc/o7/rvJAOe8s7isoTQYf8APFU=";
      };

      # packageManager: pnpm@11.28.5 (nixpkgs pnpm_11 lags a bit; tolerated);
      # pnpm >= 11 needs fetcher version 4.
      pnpm = pnpm_11;

      nativeBuildInputs = [
        nodejs
        pnpm
        pnpmConfigHook
        makeBinaryWrapper
        xz
      ]
      # patchelf нужен напрямую (officialNodeFix): RPATH в бандл не пишем, поэтому
      # autoPatchelf для него не вызываем; хук оставлен ради dontAutoPatchelf — дерево
      # воркспейса и остальные ELF должны остаться как есть.
      ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook patchelf ];

      buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
        # libstdc++ for the official node's rpath (it links libstdc++.so.6
        # dynamically; the glibc interpreter comes from stdenv itself).
        stdenv.cc.cc.lib
      ];

      dontAutoPatchelf = true;
      # strip -S -p runs after the installPhase autoPatchelf and corrupts the
      # patched official node (patchelf moved .dynstr out of its segment:
      # "allocated section '.dynstr' not in segment" → runtime
      # "undefined symbol: , version", exit 127; reproduced locally 2026-09).
      # The upstream binary ships stripped already; $out/lib and $out/bin hold
      # nothing else ELF (bin is a shell wrapper).
      dontStrip = true;

      # Full workspace install (no --filter): the release build compiles every
      # package (host + client TS aggregates, web frontend, native addons).
      pnpmWorkspaces = [ ];

      pnpmDeps = fetchPnpmDeps {
        inherit pname version src pnpm;
        pnpmWorkspaces = [ ];
        fetcherVersion = 4;
        # FOD hash of the materialized store; pinned from the stub-hash build's
        # `got:` output.
        hash = "sha256-C9Aw9AS4r7zubaEuT6mLXQ+AhhMVlTxPZRKTpzRUkcU=";
      };

      env.NODE_OPTIONS = "--max-old-space-size=4096";
      # fetchFromGitHub provides no .git; client-build-environment.ts reads this
      # public value instead of spawning `git rev-parse HEAD`, and its dirty
      # probe treats a missing git as "no metadata" (no dirty marker).
      env.DSH_CLIENT_COMMIT_HASH = "687f282e8625c6b8d11ff58211a90524be2e4317";

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

        # The official nodejs.org runtime (see officialNode): чиним только ELF-биты
        # интерпретатора, RPATH не пишем (см. officialNodeFix). Патчим здесь, а не в
        # fixup, чтобы installCheck мог его запустить.
        mkdir -p $out/lib/official-node
        tar -xJf ${officialNode} --strip-components=1 -C $out/lib/official-node
        ${officialNodeFix}

        # The launcher entry (apps/cli) is a plain ESM script whose entry guard
        # is `import.meta.main` — needs Node >= 22.19/24 (see upstream engines;
        # older nodes silently exit 0 without printing anything).
        mkdir -p $out/bin
        makeWrapper $out/lib/official-node/bin/node $out/bin/dsh \
          --prefix PATH : "$out/lib/official-node/bin:${lib.makeBinPath [ nodejs ]}" \
          --add-flags "$out/share/deepseek-harness/apps/cli/lib/bin.js"

        runHook postInstall
      '';

      # The CLI reports the upstream package.json version (0.2.1-alpha.3), not the
      # nix -unstable- suffix, so no versionCheckHook; check the entry point and
      # the version prefix manually instead.
      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        v=$($out/bin/dsh --version)
        echo "dsh --version => $v"
        case "$v" in
          0.2.1-rc.2*) ;;
          *) echo "ERROR: unexpected dsh version: $v" >&2; exit 1 ;;
        esac
        $out/bin/dsh --help > /dev/null

        # The boot resolves Node's internal ESM/CJS loader modules through
        # node-addon-require-builtin; on a wrong node binary this throws
        # Unsupported/no-getter before any profile can start.
        $out/lib/official-node/bin/node -e "
          const { createRequire } = require('node:module');
          const req = createRequire('$out/share/deepseek-harness/apps/cli/lib/bin.js');
          req('node-addon-require-builtin').requireBuiltin('internal/modules/esm/loader');
          console.log('requireBuiltin smoke => ok');
        "

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
