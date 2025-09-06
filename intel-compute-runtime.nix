{ inputs }:
(self: super: {
  intel-compute-runtime =
    with super;
    intel-compute-runtime.overrideAttrs (oldAttrs: rec {
      version = "25.22.33944.13";
      src = fetchFromGitHub {
        owner = "intel";
        repo = "compute-runtime";
        rev = version;
        hash = "sha256-l0GTcDTQLv/IszagPRVSoWiGzDNcfoU9GfHzn1WE26Q=";
      };
    });
})
