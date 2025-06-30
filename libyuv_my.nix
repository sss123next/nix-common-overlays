{ inputs }:
self: super: {
  libyuv_my =
    with super;
    libyuv.overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://chromium.googlesource.com/libyuv/libyuv/";
        ref = "main";
        rev = "5fb6c8cbe3a68d4c74f0e3166bdc33623cc5f8fe";
      };
      patches = [ ];
    });
}
