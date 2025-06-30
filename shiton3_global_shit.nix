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
    };
  };
  pythonPackages = python3.pkgs;
  python3Packages = python3.pkgs;
}
