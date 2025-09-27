{ inputs }:
self: super: {
  lcevcdec_my =
    with super;
    (lcevcdec.override { }).overrideAttrs (oldAttrs: rec {
      version = "2025-09-09";
      src = fetchGit {
        url = "https://github.com/v-novaltd/LCEVCdec";
        ref = "main";
        rev = "2f2df404fd2f61a6286bbe8cc5920995316f468b";
      };
    });
}
