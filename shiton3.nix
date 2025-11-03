{ inputs }:
self: super: rec {
  shiton3 =
    with super;
    python314.override {
      bluezSupport = false;
 #     x11Support = false;
      #      enableGIL = false;
      stripTests = true;
      enableOptimizations = true;
      packageOverrides = final: prev: {
        requests =
          with prev;
          requests.overrideAttrs (old: rec {
            version = "2.32.5";
            pname = "requests";
            patches = [ ];
            src = fetchPypi {
              inherit pname version;
              hash = "sha256-VTZUF3NOsYJVWQqf+euX6eHaho1MzWQCOZ6vaK8gp2A=";
            };
          });

        websockets =
          with prev;
          websockets.overrideAttrs (old: rec {
            version = "15.0.1";
            pname = "websockets";
            #patches = [];
            patchPhase = ''
              rm tests/asyncio/test_server.py
              rm tests/asyncio/test_client.py
              rm tests/asyncio/test_connection.py
            '';
            doCheck = false;
            #nativeCheckInputs = [];

            pythonImportsCheck = [ ];
            unittestCheckPhase = [ ];
            src = fetchFromGitHub {
              inherit pname version;
              owner = "aaugustin";
              repo = pname;
              rev = "refs/tags/${version}";
              hash = "sha256-eyNLKXSfC204bF9Zu6uvH7+XZpy3XyvuOSNlwoJTNq8=";
            };
          });

      };
    };
  #  pythonPackages = shiton3.pkgs;
  #  python3Packages = shiton3.pkgs;
}
