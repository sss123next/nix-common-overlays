{ inputs }:
self: super: {
  vcmi_my =
    with super;
    vcmi.overrideAttrs (old: rec {
      cmakeFlags = old.cmakeFlags ++ [ lib.cmakeBool "ENABLE_EDITOR" false];
    });
}
