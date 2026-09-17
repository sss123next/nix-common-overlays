{ inputs }:
self: super: {
  qwen-code =
    with super;
    buildNpmPackage (finalAttrs: {
      pname = "qwen-code";
      version = "0.24.0";

      src = fetchFromGitHub {
        owner = "QwenLM";
        repo = "qwen-code";
        tag = "v${finalAttrs.version}";
        hash = "sha256-FwZZ5Md1uqYwKG2LpCwo6k1IWa50+1G5tFFEa9PORPg=";
      };

      npmDepsFetcherVersion = 2;
      npmDepsHash = "sha256-w0hflbYxUH4fRZNW7Tef9ZyBvPnRorufkwxCT1R0wtE=";

      # npm 11 incompatible with fetchNpmDeps
      # https://github.com/NixOS/nixpkgs/issues/474535
      nodejs = nodejs_22;

      nativeBuildInputs = [
        jq
        pkg-config
        git
      ];

      buildInputs = [
        ripgrep
        glib
        libsecret
      ];

      postPatch = ''
        # patches below remove node-pty and keytar dependencies which cause build fail on Darwin
        # should be conditional on platform but since package-lock.json is patched it changes its hash
        # though seems like these dependencies are not really required by the package
        ${jq}/bin/jq '
          del(.packages."node_modules/node-pty") |
          del(.packages."node_modules/@lydell/node-pty") |
          del(.packages."node_modules/@lydell/node-pty-darwin-arm64") |
          del(.packages."node_modules/@lydell/node-pty-darwin-x64") |
          del(.packages."node_modules/@lydell/node-pty-linux-arm64") |
          del(.packages."node_modules/@lydell/node-pty-linux-x64") |
          del(.packages."node_modules/@lydell/node-pty-win32-arm64") |
          del(.packages."node_modules/@lydell/node-pty-win32-x64") |
          del(.packages."node_modules/keytar") |
          walk(
            if type == "object" and has("dependencies") then
              .dependencies |= with_entries(select(.key | (contains("node-pty") | not) and (contains("keytar") | not)))
            elif type == "object" and has("optionalDependencies") then
              .optionalDependencies |= with_entries(select(.key | (contains("node-pty") | not) and (contains("keytar") | not)))
            else .
            end
          ) |
          walk(
            if type == "object" and has("peerDependencies") then
              .peerDependencies |= with_entries(select(.key | (contains("node-pty") | not) and (contains("keytar") | not)))
            else .
            end
          )
        ' package-lock.json > package-lock.json.tmp && mv package-lock.json.tmp package-lock.json
      '';

      postConfigure = ''
        # Provide stub type declaration for @lydell/node-pty (needed by core tsc, but native addon removed)
        mkdir -p node_modules/@lydell/node-pty
        cat > node_modules/@lydell/node-pty/node-pty.d.ts << 'ENDOFPTY'
        import type { EventEmitter } from 'node:events';
        export interface IPty {
          pid: number;
          write(data: string): void;
          resize(cols: number, rows: number): void;
          kill(signal?: string): void;
          onData: EventEmitter<string>;
          onExit: EventEmitter<{ exitCode: number; signal?: number }>;
        }
        export function spawn(command: string, args?: string[], options?: Record<string, unknown>): IPty;
        export {};
        ENDOFPTY
        echo '{"name":"@lydell/node-pty","version":"1.2.0-beta.10","main":"node-pty.d.ts","types":"node-pty.d.ts"}' > node_modules/@lydell/node-pty/package.json

        # Patch all shebangs recursively (workspace bins in sub-dirs have /usr/bin/env)
        patchShebangs .
      '';

      buildPhase = ''
        runHook preBuild

        # Build internal packages in dependency order (mirrors scripts/build.js)
        # 1. core (foundation package)
        npm run build --workspace=packages/core
        # 2. channel-base (base channel infrastructure)
        npm run build --workspace=packages/channels/base
        # 3. channel adapters (depend on channel-base)
        npm run build --workspace=packages/channels/telegram
        npm run build --workspace=packages/channels/weixin
        npm run build --workspace=packages/channels/dingtalk
        npm run build --workspace=packages/channels/wecom
        npm run build --workspace=packages/channels/feishu
        npm run build --workspace=packages/channels/qqbot
        npm run build --workspace=packages/channels/github
        npm run build --workspace=packages/channels/dws
        npm run build --workspace=packages/channels/gitlab
        # 4. audio-capture (native microphone backend)
        npm run build --workspace=packages/audio-capture
        # 5. acp-bridge (depends on core)
        npm run build --workspace=packages/acp-bridge
        # 6. sdk-typescript (build-time dep)
        npm run build --workspace=packages/sdk-typescript
        # 7. web-shell (document renderer, required by web-templates)
        npm run build --workspace=packages/web-shell
        # 8. web-templates (embeddable web templates)
        npm run build --workspace=packages/web-templates

        npm run generate
        npm run bundle

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/share/qwen-code
        cp -r dist/* $out/share/qwen-code/
        # Install production dependencies only
        npm prune --production
        cp -r node_modules $out/share/qwen-code/
        # Remove broken symlinks that cause issues in Nix environment
        find $out/share/qwen-code/node_modules -type l -delete || true
        patchShebangs $out/share/qwen-code
        ln -s $out/share/qwen-code/cli.js $out/bin/qwen

        runHook postInstall
      '';

      meta = {
        description = "Coding agent that lives in digital world";
        homepage = "https://github.com/QwenLM/qwen-code";
        mainProgram = "qwen";
        license = lib.licenses.asl20;
        platforms = lib.platforms.all;
        maintainers = with lib.maintainers; [
          lonerOrz
        ];
      };
    });
}
