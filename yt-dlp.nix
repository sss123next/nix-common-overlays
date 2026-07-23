{ inputs }:
self: super: {
  yt-dlp =
    with super;
    with shiton3.pkgs;
    shiton3.pkgs.buildPythonPackage {

      pname = "yt-dlp";
      version = "2026.7.4";
      #  format = "setuptools";
      pyproject = true;
      src = fetchGit {
        url = "https://github.com/yt-dlp/yt-dlp";
        ref = "master";
        #    rev = "882e3b753c79c7799ce135c3a5edb72494b576af";
        submodules = true;
      };
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
      ];
      makeWrapperArgs =
        let
          packagesToBinPath = [
            atomicparsley
            self.ffmpeg_my
            rtmpdump
          ];
        in
        lib.optionalString (packagesToBinPath != [ ]) [
          ''--prefix PATH : "${lib.makeBinPath packagesToBinPath}"''
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
