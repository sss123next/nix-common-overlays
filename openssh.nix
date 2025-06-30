{ inputs }:
self: super: {
  openssh =
    with super;
    (openssh.override { openssl = libressl; }).overrideAttrs (old: rec {
      doCheck = false;
    });
}
