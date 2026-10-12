{ inputs }:
self: super: {
  sillytavern = with super;
    let
      version = "2026-10-03";
      src = fetchGit {
        url = "https://github.com/SillyTavern/SillyTavern";
        ref = "staging";
        rev = "ad29cbda62e92f145e44d7a10398a38af22ca986";
      };
    in
    buildNpmPackage (finalAttrs: {
      pname = "sillytavern";
      inherit version src;

      npmDepsHash = "sha256-wAVmQuchjDXh7sTj8Q7+bJJoYCi7JdvlEeC5G9VtjMU=";

      dontNpmBuild = true;

      nativeBuildInputs = [
        makeBinaryWrapper
      ];

      patches = [
        ./patches/sillytavern-esc-to-ctrl-esc.patch
      ];

      postPatch = ''
        # .npmrc ломает npm pack
        rm .npmrc

        # Отключаем вызов git в getVersion() — в store нет .git репозитория
        substituteInPlace src/util.js \
          --replace-fail \
          "if (commandExistsSync('git')) {" \
          "if (false) {"
      '';

      # Собираем webpack в dist/_webpack (forceDist mode)
      # webpack.config.js — ESM с top-level await, требует --experimental-vm-modules
      buildPhase = ''
        runHook preBuild

        export NODE_ENV=production
        mkdir -p dist/_webpack

        # webpack.config.js вызывает getVersion() на верхнем уровне.
        # После postPatch git не вызывается, версия берётся из package.json — ок.
        node --input-type=module <<'EOF'
        import getPublicLibConfig from "./webpack.config.js";
        import webpack from "webpack";

        globalThis.DATA_ROOT = "data";
        const cfg = getPublicLibConfig({ forceDist: true, pruneCache: false });
        const compiler = webpack(cfg);

        compiler.run((err, stats) => {
          if (err) { console.error(err); process.exit(1); }
          const output = stats.toString({ colors: false, preset: "minimal" });
          console.log(output);
          compiler.close(() => process.exit(stats.hasErrors() ? 1 : 0));
        });
        EOF

        runHook postBuild
      '';

      # npmInstallHook запускает npm pack, который игнорирует dist/ (через .npmignore).
      # Копируем то, что не попало в pack, вручную.
      # Используем preInstall (до npmInstallHook), т.к. после npm pack dist уже будет в $out
      preInstall = ''
        # Сохраняем webpack output и default/ до npm pack
        mkdir -p /build/_preserve
        if [ -d dist/_webpack ]; then
          cp -r dist/_webpack /build/_preserve/
        fi
        if [ -d default ]; then
          cp -r default /build/_preserve/
        fi
      '';

      postInstall = ''
        # Создаём необходимые директории
        mkdir -p $out/lib/node_modules/sillytavern/{backups,public/scripts/extensions/third-party,data}

        # Восстанавливаем webpack output
        if [ -d /build/_preserve/_webpack ]; then
          mkdir -p $out/lib/node_modules/sillytavern/dist
          cp -r /build/_preserve/_webpack $out/lib/node_modules/sillytavern/dist/
        fi

        # Копируем дефолтный конфиг и контент в data/ (рядом с node_modules)
        if [ -d /build/_preserve/default ]; then
          cp -r /build/_preserve/default/* $out/lib/node_modules/sillytavern/data/
        fi
      '';

      # Обёртка для --global mode (XDG-директории)
      postFixup = ''
        # Патчим constants.js: глобальные расширения (third-party) должны
        # читаться из DATA_ROOT, а не из read-only store. DATA_ROOT
        # устанавливается в server.js ДО импорта users.js (который использует
        # эту константу), но после импорта constants.js (чистые константы).
        # Поэтому используем getter, который резолвится при обращении.
        substituteInPlace $out/lib/node_modules/sillytavern/src/constants.js \
          --replace-fail \
          "globalExtensions: 'public/scripts/extensions/third-party'" \
          "get globalExtensions() { const d = globalThis.DATA_ROOT; return d ? d + '/../_extensions' : 'public/scripts/extensions/third-party'; }"

        # Патчим webpack-serve.js — пропускаем компиляцию, если output уже есть.
        # Собранный на этапе buildPhase lib.js уже скопирован в DATA_ROOT/_webpack.
        # webpack-serve.js: runWebpackCompiler → всегда запускает webpack.
        # Заменяем на проверку наличия output файла.
        substituteInPlace $out/lib/node_modules/sillytavern/src/middleware/webpack-serve.js \
          --replace-fail \
          "devMiddleware.runWebpackCompiler = ({ forceDist = false, pruneCache = false } = {}) => {" \
          "devMiddleware.runWebpackCompiler = async ({ forceDist = false, pruneCache = false } = {}) => { const _cfg = getPublicLibConfig({ forceDist, pruneCache }); const _outPath = _cfg.output?.path; const _outFile = _cfg.output?.filename; try { const { existsSync } = await import('node:fs'); if (_outPath && _outFile && existsSync(_outPath + '/' + _outFile)) { console.log(); console.log('Frontend libraries already compiled, skipping...'); return; } } catch {}"

        rm -f $out/bin/sillytavern

        # Shell-скрипт-обёртка для --global mode (symlink webpack dist).
        cat > $out/bin/sillytavern << WRAPPER
        #!${bash}/bin/bash -e
        export NODE_ENV=production
        export PATH="${git}/bin:\$PATH"

        cd "$out/lib/node_modules/sillytavern"

        # --global mode: данные в XDG-директориях
        DATA_ROOT="\''${XDG_DATA_HOME:-\$HOME/.local/share}/SillyTavern/data"
        mkdir -p "\$DATA_ROOT" "\$DATA_ROOT/../_extensions"

        exec ${nodejs}/bin/node "$out/lib/node_modules/sillytavern/server.js" --global "\$@"
        WRAPPER
        chmod +x $out/bin/sillytavern

        # Standalone mode (data в текущей директории, без --global)
        makeWrapper ${nodejs}/bin/node $out/bin/sillytavern-standalone \
          --add-flags "$out/lib/node_modules/sillytavern/server.js" \
          --chdir "$out/lib/node_modules/sillytavern" \
          --set NODE_ENV production \
          --prefix PATH : ${lib.makeBinPath [ git ]}
      '';

      meta = {
        description = "LLM Frontend for Power Users";
        longDescription = ''
          SillyTavern is a user interface you can install on your computer (and Android phones) that allows you to interact with
          text generation AIs and chat/roleplay with characters you or the community create.

          This package makes a global installation — data and config go to XDG directories
          (~/.local/share/sillytavern and ~/.config/sillytavern).
          See https://docs.sillytavern.app/installation/#global--standalone-mode for details.
        '';
        homepage = "https://docs.sillytavern.app/";
        license = lib.licenses.agpl3Only;
        mainProgram = "sillytavern";
        platforms = [ "x86_64-linux" "aarch64-linux" ];
      };
    });
}
