{ inputs }:
final: prev: rec {
  python3 = prev.python3.override {
    packageOverrides = python-final: python-prev: {
      eventlet =
        with python-prev;
        eventlet.overridePythonAttrs (old: rec {
          doCheck = false; # Disable tests
          doInstallCheck = false; # Disable install checks
          nativeCheckInputs = [ ];
          pythonImportsCheck = [ ];
          checkPhase = "";
          tests = [ ];
          disabledTests = [
            # AssertionError: Expected single line "pass" in stdout
            "test_fork_after_monkey_patch"
            # Tests requires network access
            "test_getaddrinfo"
            "test_hosts_no_network"
            # flaky test, depends on builder performance
            "test_server_connection_timeout_exception"
            "test_sendall_timeout"
          ];
          #        catchConflicts = false;# Disable dependency conflict checks
        });
      twisted =
        with python-prev;
        twisted.overridePythonAttrs (old: rec {
          doCheck = false; # Disable tests
          doInstallCheck = false; # Disable install checks
          checkPhase = "";
        });
      django =
        with python-prev;
        django.overridePythonAttrs (old: rec {
          doCheck = false; # Disable tests
          doInstallCheck = false; # Disable install checks
          checkPhase = "";
        });
      librosa =
        with python-prev;
        librosa.overridePythonAttrs (old: rec {
          doCheck = false; # Disable tests
          doInstallCheck = false; # Disable install checks
          checkPhase = "";
        });
      uvloop =
        with python-prev;
        uvloop.overridePythonAttrs (old: rec {
          doCheck = false; # Disable tests
          doInstallCheck = false; # Disable install checks
          checkPhase = "";
        });
      pyopenssl =
        with python-prev;
        pyopenssl.overridePythonAttrs (old: rec {
          # TestConnection.test_moving_buffer_behavior — тест на тайминги буфера: под
          # нагрузкой параллельной сборки вместо BAD_WRITE_RETRY прилетает WantWriteError
          # («assert None in ('bad write retry', 'BAD_WRITE_RETRY')»), и падает весь
          # buildEnv через service-identity → trustme/trio/websockets → yt-dlp.
          # В isolation проходит, --reruns 3 не спасает (4/4 падают в нагруженном билдере).
          disabledTests = (old.disabledTests or [ ]) ++ [
            "test_moving_buffer_behavior"
          ];
        });
    };
  };

  # Sphinx >=9 не кладёт _static/jquery.js в man-билдер, а nixpkgs делает там rm без -f
  # (fa7eda094267), и installSphinxPhase падает: «rm: cannot remove
  # '.sphinx/man/man/_static/jquery.js'». Upstream починил только 2e3c26853 (2026-10-21)
  # через склейку sphinxBuilders; здесь — просто толерантный rm.
  todoman = prev.todoman.overrideAttrs (old: rec {
    preInstallSphinx = ''
      rm -f .sphinx/man/man/_static/jquery.js \
            .sphinx/man/man/_static/_sphinx_javascript_frameworks_compat.js
      rmdir .sphinx/man/man/_static/ 2>/dev/null || true
    '';
  });

  # GDAL fork-тест фейлится на удалённом билдере в изолированном окружении:
  #   test_gdalalg_raster_tile_fork_forced — «Fork failed»
  gdal = prev.gdal.overrideAttrs (old: {
    disabledTests = (old.disabledTests or []) ++ [
      "test_gdalalg_raster_tile_fork_forced"
    ];
  });
  gdalMinimal = prev.gdalMinimal.overrideAttrs (old: {
    disabledTests = (old.disabledTests or []) ++ [
      "test_gdalalg_raster_tile_fork_forced"
    ];
    # Вариант B — если disabledTests не работает, полное отключение тестов:
    # doInstallCheck = false;
    # doCheck = false;
  });

  pythonPackages = python3.pkgs;
  python3Packages = python3.pkgs;
}
