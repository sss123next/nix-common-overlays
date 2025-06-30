{ inputs }:
self: super: {
  exiv2_my =
    with super;
    exiv2.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/Exiv2/exiv2";
        ref = "main";
                      rev = "316cb55574b33d8d4b3e3c240bf3f9e881135e52";
#        rev = "4af576c067b72a1968066202eec1ddb577383a63";
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
