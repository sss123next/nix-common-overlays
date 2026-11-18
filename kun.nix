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
      version = "0.4.5";

      src = fetchFromGitHub {
        owner = "KunAgent";
        repo = "Kun";
        rev = "v0.4.5";
        hash = "sha256-tLAp9p8+4qOiG/hGDAxpNLnhNSvJ4HRrU/Hun9Sj8yY=";
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
          hash = "sha256-1KDgf9c0xx3vktRkWuJ6zqxSLog+Ceo2zBnYr77Ku9E=";
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

      # Both workarounds are still required on 0.4.5. Re-verified offline against
      # the prefetched npmDeps cache rather than carried over — that is how the
      # wrong attribution in this comment got fixed:
      #
      #  * --legacy-peer-deps — the ROOT `npm ci` dies with EUSAGE without it:
      #    "Invalid: lock file's @radix-ui/react-popover@1.1.23 does not satisfy
      #    @radix-ui/react-popover@1.1.6" (plus primitive, react-compose-refs, …),
      #    because @excalidraw/excalidraw pins older @radix-ui/* than the hoisted
      #    tree. Online npm re-resolves; offline it cannot. The kun/ subtree is
      #    NOT the offender — it installs fine without the flag; the 0.4.1
      #    revision of this comment claimed the opposite.
      #
      #  * rxjs in dependencies — the price of that flag: npm then skips every
      #    peer:true lockfile entry, so node_modules/rxjs is missing even though
      #    @univerjs/core declares peerDependencies.rxjs ">=7.0.0", and
      #    electron-vite dies with "Rollup failed to resolve import rxjs".
      #    Measured on 0.4.5: install with the flag is green, rxjs absent.
      #    Promoting it to a direct dependency installs it; node_modules ships
      #    in $out, so runtime resolves it.
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

      # makeCacheWritable: an offline `npm ci` writes _logs into its cache dir,
      # which is the read-only npmDeps output.
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

        # Same anchoring applies to bundled assets. All of these lookups branch
        # on app.isPackaged (bundled-skill-resources.ts, pet-importer.ts,
        # officecli-resources.ts): packaged builds use process.resourcesPath,
        # ours — Electron is handed out/main as a directory — are unpackaged and
        # read <appPath>/resources/<name>, i.e. out/main/resources.
        #
        #   bundled-skills  skills shipped with the app
        #   pets            desktop companions (0.4.5): pet.json + webp sheets
        #   officecli       license/provenance stub only, the binary itself is
        #                   downloaded on demand into userData
        #   ppt-toolchain   Python helpers for PPT/PPTX export
        #
        # resources/bundled-extensions existed through 0.4.1 and is gone upstream
        # now, though the JS still names it — hence the -d guard per directory.
        # resources/whisper is deliberately skipped: 25 MiB of prebuilt
        # multi-platform binaries that would need patchelf, and the feature
        # degrades to "not installed" when absent.
        mkdir -p "$out/share/kun/out/main/resources"
        for res in bundled-skills pets officecli ppt-toolchain; do
          if [ -d "resources/$res" ]; then
            cp -r "resources/$res" "$out/share/kun/out/main/resources/"
          fi
        done

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
