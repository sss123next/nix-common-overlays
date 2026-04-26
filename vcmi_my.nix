{ inputs }:
self: super: {
  vcmi_my =
    with super;
    (vcmi.override{stdenv = llvmPackages.stdenv;}).overrideAttrs (old: rec {
      cmakeFlags = old.cmakeFlags ++ [ "-DENABLE_EDITOR=FALSE" ];
    });
}
