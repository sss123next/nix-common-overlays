{ inputs }:
self: super: {
  # Kun — local-first general-purpose agent (coding / writing / design /
  # research / automation). Electron 43 + electron-vite monorepo, pnpm
  # workspaces (packages/*) plus an npm-managed kun/ CLI subtree. Built with a
  # plain stdenv.mkDerivation since buildElectronApplication /
  # buildNodeModulesWithPnpm are no longer exported by current nixpkgs.
  kun =
    with super;
    stdenv.mkDerivation (finalAttrs: {
      pname = "kun";
      version = "0.3.10";

      src = fetchFromGitHub {
        owner = "KunAgent";
        repo = "Kun";
        rev = "v0.3.10";
        hash = "sha256-lZUxRzVaDO8Iq+YMHg6G7dxtJUK1SvHuHfacVLD94j4=";
      };

      # Two separate lockfiles — root (kun-gui workspaces) and kun/ subtree (CLI).
      # The root postinstall.cjs triggers `npm --prefix kun` during npm rebuild
      # (inside npmConfigHook), BEFORE postConfigure runs. So both caches must be
      # merged into a single FOD — pattern: super-productivity.
      #
      # fetcherVersion = 2 caches packument metadata (fixes ENOTCACHED for
      # peer/workspace deps that prefetch-npm-deps v1 does not cache).
      npmDeps = stdenv.mkDerivation (
        lib.fetchers.normalizeHash { } {
          pname = "kun-deps";
          inherit (finalAttrs) version src;

          nativeBuildInputs = [
            prefetch-npm-deps
            rsync
          ];

          __structuredAttrs = true;
          strictDeps = true;

          env = {
            FORCE_EMPTY_CACHE = true;
            NPM_FETCHER_VERSION = "2";
            SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
          };

          buildPhase = ''
            mkdir -p $out
            # Root lockfile
            prefetch-npm-deps package-lock.json /tmp/cache
            rsync -a /tmp/cache/ $out
            rm -rf /tmp/cache
            # kun/ subtree lockfile
            prefetch-npm-deps kun/package-lock.json /tmp/cache
            rsync -a /tmp/cache/ $out
            rm -rf /tmp/cache
            # Root lockfile must be in $out for npmConfigHook consistency check
            cp package-lock.json $out
          '';

          dontInstall = true;
          outputHashMode = "recursive";
          hash = "sha256-bk3boogFoACtnxpzOm8abWUUIdxhzxZzXsKrbPG5ewQ=";
        }
      );

      electron = electron_43;

      env = {
        ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
        npm_config_audit = "false";
        npm_config_fund = "false";
      };

      nativeBuildInputs = [
        asar
        faketty
        nodejs
        makeWrapper
        installShellFiles
        npmHooks.npmConfigHook
      ];

      # Native modules compiled against Electron (better-sqlite3, node-pty,
      # tesseract.js, etc.) need a python for node-gyp.
      # No autoPatchelfHook — it breaks electron child processes (GPU/renderer).
      # Instead, LD_LIBRARY_PATH in the wrapper provides sharp/vips/libstdc++.
      buildInputs = [
        python3
        vips
        stdenv.cc.cc
        libXtst
        libxkbcommon
      ];

      buildPhase = ''
        runHook preBuild
        faketty npm run build
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/share/kun"
        cp -r out "$out/share/kun/"
        cp -r node_modules "$out/share/kun/"
        cp -r kun "$out/share/kun/"
        cp -r packages "$out/share/kun/"
        cp -r vendor "$out/share/kun/"
        cp package.json "$out/share/kun/"

        # electron-vite builds into out/main/ but the app resolves
        # kun/dist/cli relative to app.getAppPath() which is out/main/.
        # The kun/ subtree builds into kun/dist/, so copy dist/ into out/main/.
        # MUST be a real copy, not a symlink — Node.js ESM resolves symlinks for
        # import.meta.url but process.argv[1] keeps the caller's path, breaking
        # the manager-entry.js guard (import.meta.url === pathToFileURL(argv[1])).
        mkdir -p "$out/share/kun/out/main/kun"
        cp -r "$out/share/kun/kun/dist" "$out/share/kun/out/main/kun/dist"

        mkdir -p "$out/share/icons/hicolor/512x512/apps"
        cp src/asset/img/kun.png "$out/share/icons/hicolor/512x512/apps/kun.png"

        # Manual patchelf for specific native modules that need glibc libs.
        # NOT using autoPatchelfHook — it would patch electron internals.
        for nodebin in \
          node_modules/@img/sharp-linux-x64/lib/sharp-linux-x64-*.node \
          node_modules/@computer-use/libnut-linux/build/Release/libnut.node \
          node_modules/better-sqlite3/build/Release/better_sqlite3.node \
          node_modules/@napi-rs/canvas-linux-x64-gnu/skia.linux-x64-gnu.node \
          node_modules/@trycua/cua-driver-linux-x64-gnu/cua_driver_sdk.so \
        ; do
          if [ -f "$out/share/kun/$nodebin" ]; then
            patchelf --set-rpath \
              "${lib.makeLibraryPath [ vips stdenv.cc.cc libXtst libxkbcommon ]}:$(patchelf --print-rpath "$out/share/kun/$nodebin" 2>/dev/null || true)" \
              "$out/share/kun/$nodebin" 2>/dev/null || true
          fi
        done

        makeWrapper ${lib.getExe electron} "$out/bin/kun" \
          --add-flags "$out/share/kun/out/main/index.js" \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
          --add-flags "--disable-setuid-sandbox" \
          --add-flags "--no-first-run"

        runHook postInstall
      '';

      passthru = {
        inherit (electron_43) version;
      };

      meta = with lib; {
        description = "Local-first general-purpose agent (coding / writing / design / research / automation) with GUI + TUI, MCP and OpenAI-compatible backend";
        homepage = "https://github.com/KunAgent/Kun";
        changelog = "https://github.com/KunAgent/Kun/releases";
        license = {
          free = false;
          fullName = "PolyForm Noncommercial License 1.0.0";
          redistributable = true;
          deprecated = false;
        };
        platforms = platforms.linux;
        mainProgram = "kun";
      };
    });
}
