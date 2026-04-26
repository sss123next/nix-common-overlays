{ inputs }:
self: super: {
  vcmi_my =
    with super;
    vcmi.overrideAttrs (old: rec {
      cmakeFlags = old.cmakeFlags ++ [ "-DENABLE_EDITOR=FALSE" ];
    });
}
