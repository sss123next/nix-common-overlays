{ inputs }:
mod: orig: {
  rsync =
    with orig;
    (rsync.override { stdenv = gcc13Stdenv; }).overrideAttrs (old: rec {
      version = "3.4.1";
      src = fetchurl {
        url = "mirror://samba/rsync/src/rsync-${version}.tar.gz";
        hash = "sha256-KSS8s6Hti1UfwQH3QLnw/gogKxFQJ2R89phQ1l/YjFI=";
      };
      #          configureFlags = old.configureFlags ++ [ "--disable-md2man" ];
      #          nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook ];
      patches = [ ];
    });
}
