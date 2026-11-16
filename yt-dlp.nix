{ inputs }:
self: super: {
  yt-dlp =
    with super;
    with shiton3.pkgs;
    let
      src = fetchGit {
        url = "https://github.com/yt-dlp/yt-dlp";
        ref = "master";
        #    rev = "882e3b753c79c7799ce135c3a5edb72494b576af";
        submodules = true;
      };

      # В pyproject версия объявлена dynamic и берётся из yt_dlp/version.py, а src —
      # fetchGit master без rev: любой хардкод в version неминуемо разъезжается с
      # источником, и сборка падала в pythonMetadataCheckPhase (drv 2026.8.19 против
      # METADATA 2026.10.21). Читаем версию прямо из источника; сравнивает хук её через
      # packaging.version.parse, так что ведущие нули (2026.08.19) нормализуются сами.
      versionFromSrc = builtins.tryEval (builtins.head (builtins.filter (x: x != null)
        (map (builtins.match "^__version__[ ]*=[ ]*[\"']([^\"']+)[\"']")
          (lib.splitString "\n" (builtins.readFile (src + "/yt_dlp/version.py"))))));
    in
    shiton3.pkgs.buildPythonPackage {

      pname = "yt-dlp";
      # Fallback не даёт eval упасть, если upstream переименует version.py: тогда
      # споткнётся только сборка yt-dlp на проверке метаданных, а не всё окружение.
      version = if versionFromSrc.success then builtins.head versionFromSrc.value else "2026.10.21";
      #  format = "setuptools";
      pyproject = true;
      inherit src;
      nativeBuildInputs = [ hatchling ];
      propagatedBuildInputs = [
        brotli
        certifi
        mutagen
        pycryptodomex
        websockets
        requests
        urllib3
        deno
        yt-dlp-ejs
        # curl-cffi — для impersonation (имитация TLS-отпечатка браузера).
        # Без него yt-dlp не может подделать TLS-отпечаток, и YouTube охотнее
        # отдаёт 429 на субтитры и другие запросы.
        curl-cffi
      ];
      # makeWrapperArgs — список ОТДЕЛЬНЫХ аргументов: wrap-python-hook больше не бьёт
      # строки по пробелам, поэтому прежний вариант одной строкой
      # «--prefix PATH : "…"» уходил в makeWrapper единым аргументом и сборка падала в
      # fixupPhase с «makeWrapper doesn't understand the arg --prefix PATH : …».
      # Прежний lib.optionalString дело только усугублял: он возвращает строку, а не список.
      makeWrapperArgs = [
        "--prefix" "PATH" ":" (lib.makeBinPath [
          atomicparsley
          self.ffmpeg_my
          rtmpdump
        ])
      ];

      setupPyBuildFlags = [
        "build_lazy_extractors"
      ];

      doCheck = false;
      postInstall = ''
        ln -s "$out/bin/yt-dlp" "$out/bin/youtube-dl"
      '';

      meta = with lib; {
        homepage = "https://github.com/yt-dlp/yt-dlp/";
        description = "Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)";
        longDescription = ''
          yt-dlp is a youtube-dl fork based on the now inactive youtube-dlc.

          youtube-dl is a small, Python-based command-line program
          to download videos from YouTube.com and a few more sites.
          youtube-dl is released to the public domain, which means
          you can modify it, redistribute it or use it however you like.
        '';
        license = licenses.unlicense;
        mainProgram = "yt-dlp";
        #    maintainers = with maintainers; [ mkg20001 SuperSandro2000 marsam ];
      };
    };
}
