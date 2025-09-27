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
       postPatch = ''
    substituteInPlace cmake/tools/version_files.py \
      --replace-fail "args.git_version" '"${oldAttrs.version}"' \
      --replace-fail "args.git_hash" '"${oldAttrs.src.rev}"' \
      --replace-fail "args.git_date" '"1970-01-01"'
    substituteInPlace cmake/templates/lcevc_dec.pc.in \
      --replace-fail "@GIT_SHORT_VERSION@" "${oldAttrs.version}"
  '';
    });
}
