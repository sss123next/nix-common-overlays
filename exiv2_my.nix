{ inputs }:
self: super: {
  exiv2_my =
    with super;
    exiv2.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/Exiv2/exiv2";
        ref = "main";
 #       rev = "316cb55574b33d8d4b3e3c240bf3f9e881135e52";
                rev = "479d5e14e13d16ad058e9765d190c8f2bdbe773c";
      };
      buildInputs = oldAttrs.buildInputs ++ [
        brotli
        inih
      ];
      doCheck = false;
      postInstall = ''
        remove-references-to -t ${stdenv.cc.cc} $lib/lib/*.so.*.*.* $out/bin/exiv2
      '';
      #            postFixup = "";
      outputs = [
        "out"
        "lib"
        "dev"
        "doc"
        "man"
      ];
      patches = [ ];
    });
}
