{ inputs }:
self: super: {
  # OpenHands >= 1.x — это npm-пакет @openhands/agent-canvas: React-фронтенд
  # (react-router + vite), собирается `npm run build` → build/, плюс launcher
  # (bin/agent-canvas.mjs), который в static-режиме поднимает стек:
  #   - агент-сервер и automation-бэкенд через `uvx` (PyPI, скачиваются при первом запуске),
  #   - статический сервер фронтенда и ingress-прокси (node, только builtin-модули + sirv).
  # Python-части в этом репо больше нет (она вынесена в OpenHands/software-agent-sdk),
  # поэтому здесь чисто buildNpmPackage, а python-зависимости уезжают в рантайм через uv.
  openhands =
    with super;
    let
      # uv по умолчанию ставит скачанный CPython и окружения под $HOME.
      # Если диск $HOME смонтирован с noexec (как здесь: /home), это падает
      # с "Permission denied" — и на скачанный python, и на dlopen нативных
      # расширений из окружения. Перекладываем uv-каталоги в exec-место
      # (TMPDIR), если текущие лежат на noexec-монтировании.
      # Пользовательские UV_* всегда сильнее — не трогаем, если заданы.
      uvEnvScript = writeShellScript "openhands-uv-env" ''
        _oh_noexec() {
          local d="$1" spec mp fst opts x
          while :; do
            while read -r spec mp fst opts x; do
              if [ "$mp" = "$d" ]; then
                case ",$opts," in *,noexec,*) return 0 ;; esac
                return 1
              fi
            done < /proc/self/mounts
            case "$d" in "" | "/") return 1 ;; esac
            d="''${d%/*}"
            if [ -z "$d" ]; then d=/; fi
          done
        }
        if [ -z "''${UV_CACHE_DIR-}" ] && [ -z "''${UV_PYTHON_INSTALL_DIR-}" ]; then
          if _oh_noexec "''${XDG_DATA_HOME:-$HOME/.local/share}" \
            || _oh_noexec "''${XDG_CACHE_HOME:-$HOME/.cache}"; then
            OH_UV_DIR="''${TMPDIR:-/tmp}/openhands-uv-$UID"
            export UV_PYTHON_INSTALL_DIR="$OH_UV_DIR/python"
            export UV_CACHE_DIR="$OH_UV_DIR/cache"
            export UV_TOOL_DIR="$OH_UV_DIR/tools"
          fi
        fi
      '';
    in
    buildNpmPackage (finalAttrs: {
      pname = "openhands";
      version = "1.25.0";

      src = fetchFromGitHub {
        owner = "OpenHands";
        repo = "OpenHands";
        rev = "v${finalAttrs.version}";
        hash = "sha256-KdYDr16NzKcGxWx1yXdLN487d1/dp1A174DJGAi4rWs=";
      };

      # В upstream package-lock.json 7 записей без `integrity` (у
      # @tailwindcss/oxide-wasm32-wasi — ещё и без `resolved`), на чём паникует
      # prefetch-npm-deps: "non-git dependencies should have associated integrity".
      # Патч доливает registry-метаданные (integrity/resolved из npm registry).
      patches = [ ./patches/openhands-lockfile-integrity.patch ];

      npmDepsHash = "sha256-mk9VmmKMM6gnC0H8iD72Ujg1+sEwKstyb8Se72UUFG0=";

      # devDependencies electron/playwright качают бинарники по сети в install-скриптах,
      # а нативных модулей (gypfile) в дереве нет — поэтому все lifecycle-скрипты
      # на этапе `npm rebuild` выключены. esbuild/@tailwindcss/oxide берут готовые
      # platform-пакеты из optionalDependencies, скрипты им не нужны.
      npmRebuildFlags = [ "--ignore-scripts" ];

      # `npm pack` (npmInstallHook) исполняет `prepare` → husky, которому нужен .git.
      npmPackFlags = [ "--ignore-scripts" ];

      # Ланчер спавнит дочерние процессы по PATH: `node` (ingress/static-server),
      # `uvx` (agent-server + automation), плюс git/tmux нужны агенту в рантайме.
      # Строка ниже уходит в nodejsInstallExecutables как makeWrapperArgs; без
      # __structuredAttrs список разворачивается хуком в строку, поэтому
      # многострочные вещи через makeWrapperArgs не передать — см. postFixup.
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath [
          nodejs
          uv
          git
          tmux
        ])
      ];

      # Оборачиваем сгенерированный хуком враппер ещё одним: перед запуском
      # sourced-ится uvEnvScript (guard noexec каталогов uv).
      postFixup = ''
        mkdir -p $out/libexec/openhands
        mv $out/bin/agent-canvas $out/libexec/openhands/agent-canvas
        makeWrapper $out/libexec/openhands/agent-canvas $out/bin/agent-canvas \
          --run ". ${uvEnvScript}"
      '';

      # react-router build (vite) на больших проектах упирается в heap дефолтного node.
      NODE_OPTIONS = "--max-old-space-size=8192";

      meta = {
        description = "AI-driven development: Agent Canvas UI + local agent-server stack";
        homepage = "https://github.com/OpenHands/OpenHands";
        license = lib.licenses.mit;
        mainProgram = "agent-canvas";
        platforms = lib.platforms.linux;
      };
    });
}
