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
      version = "0.4.0";

      src = fetchFromGitHub {
        owner = "KunAgent";
        repo = "Kun";
        rev = "v0.4.0";
        hash = "sha256-9PooQUVscS/Nw1Xuu540DIU7zxdwPZm6vaOyLETZ4l8=";
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
            nodejs
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
          hash = "sha256-OAI0qv5Xs21Al0lX7k9sVw5psupTEuxTiFIwGDNrMCE=";
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

      # Why BOTH of these are required (empirically, offline npm ci against the
      # prefetched npmDeps cache):
      #
      #  * `--legacy-peer-deps` — without it npm ci fails with EUSAGE
      #    ("lock file's @radix-ui/react-popover@1.1.23 does not satisfy
      #    @radix-ui/react-popover@1.1.6"): @excalidraw/excalidraw pins the old
      #    @radix-ui/* while the lockfile hoists newer ones — 0.4.0 even ships a
      #    nested @excalidraw/excalidraw/node_modules/.../react-popover@1.1.6
      #    copy, and npm's sync check still rejects the tree (16 "Invalid:"
      #    lines). Online npm can re-resolve; offline it can't.
      #
      #  * rxjs in `dependencies` — --legacy-peer-deps makes npm skip every
      #    `peer: true` lockfile entry (1741 vs 1752 pkgs). rxjs is one of them
      #    (a peer of @univerjs/core), and without node_modules/rxjs electron-vite
      #    dies with "Rollup failed to resolve import rxjs from
      #    node_modules/@univerjs/core/lib/es/facade.js". Promoting it to a
      #    direct dependency makes npm install it (1742 pkgs) and lets
      #    externalizeDepsPlugin externalize it in main/preload instead of
      #    bundling it — node_modules is shipped in $out, so runtime resolves.
      #
      # Only package.json is touched here; package-lock.json stays byte-identical
      # so npmConfigHook's consistency check against $npmDeps still passes.
      postPatch = ''
        node -e '
          const fs = require("fs");
          const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
          pkg.dependencies = pkg.dependencies || {};
          if (!pkg.dependencies.rxjs) pkg.dependencies.rxjs = "^7.8.2";
          fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
        '

        # NixOS ships no /bin/ps. The Kun runtime exec()s it directly — the
        # owned-process guard (kun/src/process/owned-process-guard.ts) and the
        # runtime identity probe (kun/src/server/runtime-process-identity.ts) —
        # and both swallow the ENOENT into "Could not verify owned process
        # group" / "Owned processes failed to exit" on every shutdown, leaving
        # spawned runtimes unverified. Point them at procps' ps instead; the
        # store path lands in the built JS and is picked up by the closure scan
        # (procps is in buildInputs).
        for f in \
          kun/src/process/owned-process-guard.ts \
          kun/src/server/runtime-process-identity.ts \
        ; do
          sed -i "s|'/bin/ps'|'${lib.getExe' procps "ps"}'|g" "$f"
        done
      '';

      makeCacheWritable = true;
      npmFlags = [ "--legacy-peer-deps" ];

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
        # /bin/ps substitute from postPatch — the built JS embeds its store
        # path, so the closure scan keeps it in runtime closure.
        procps
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
        # The kun/ subtree builds into kun/dist/, so expose it under out/main/kun/.
        #
        # dist/ MUST be a real copy, not a symlink — Node.js ESM resolves
        # symlinks for import.meta.url but process.argv[1] keeps the caller's
        # path, breaking the manager-entry.js guard
        # (import.meta.url === pathToFileURL(process.argv[1]).href): the manager
        # then silently exits 0 without ever calling main(), and the GUI fails
        # with "Service Manager did not become ready".
        #
        # node_modules/ and package.json stay symlinks (module resolution only
        # stat()s them; missing them breaks bare imports like safe-regex2).
        mkdir -p "$out/share/kun/out/main/kun"
        cp -rl "$out/share/kun/kun/dist" "$out/share/kun/out/main/kun/dist" \
          || cp -r "$out/share/kun/kun/dist" "$out/share/kun/out/main/kun/dist"
        ln -s ../../../kun/node_modules "$out/share/kun/out/main/kun/node_modules"
        ln -s ../../../kun/package.json "$out/share/kun/out/main/kun/package.json"

        # src/main/main-paths.ts anchors every preload on app.getAppPath():
        # <appPath>/out/preload/<name>.cjs (falling back to .mjs). appPath is
        # out/main — the directory handed to Electron — so the bundles must be
        # COPIED under out/main/out/preload, otherwise every window starts
        # without its preload bridge ("failed to load preload ... index.mjs").
        # Real copy, not a symlink: Electron rejects symlinked sandbox preloads
        # and ESM realpath handling would break the import.meta.url guard.
        mkdir -p "$out/share/kun/out/main/out"
        cp -r "$out/share/kun/out/preload" "$out/share/kun/out/main/out/preload"

        # Same anchoring applies to bundled assets: <appPath>/resources/...
        # (bundled-skill-resources.ts, bundled-extension-resources.ts). Only the
        # JS-side trees are copied — resources/whisper alone is 25 MiB of
        # prebuilt multi-platform binaries that would need patchelf, and that
        # feature is optional and degrades to "not installed" when absent.
        mkdir -p "$out/share/kun/out/main/resources"
        if [ -d resources/bundled-skills ]; then
          cp -r resources/bundled-skills "$out/share/kun/out/main/resources/"
        fi
        if [ -d resources/bundled-extensions ]; then
          cp -r resources/bundled-extensions "$out/share/kun/out/main/resources/"
        fi

        # electron-updater validates app.getVersion() as semver at startup;
        # "0.0" → ERR_UPDATER_INVALID_VERSION. With FILE launch Electron
        # ignores package.json (falls back to "0.0" for Kun), so the wrapper
        # launches out/main as a DIRECTORY and Electron reads version from
        # this manifest. It must equal the built version: a stale, LOWER value
        # makes autoUpdater see the app as outdated and re-download a full
        # update over the read-only store on every launch. "main" must be
        # ./index.js relative to out/main (root package.json points to
        # ./out/main/index.js — wrong here). "type": "module" keeps index.js ESM.
        cat > "$out/share/kun/out/main/package.json" <<'PKGEOF'
        {
          "name": "kun-gui",
          "productName": "Kun",
          "version": "${finalAttrs.version}",
          "type": "module",
          "main": "./index.js"
        }
        PKGEOF

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
          --add-flags "$out/share/kun/out/main" \
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
