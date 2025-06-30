{ inputs }:
self: super: {
  thrift =
    with super;
    (thrift.override { }).overrideAttrs (old: rec {
      doCheck = false;
    });
}
