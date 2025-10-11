{ inputs }:
self: super: {
  krita_my =
    with super;
    (krita.override {
      #            boost = nixpkgsmaster.boost;
      #stdenv = llvmPackages_14.stdenv;
    }).overrideAttrs
      (oldAttrs: rec {
        version = "git";
        src = fetchGit {
          url = "https://invent.kde.org/graphics/krita.git";
          ref = "master";
          #              rev = "7a694e38b5556835b7248eb840d7bed23718fb12";
          rev = "bb071e096fc431bf00a3f4e4f5a64ba69fedd51c";
        };
        patches = [ ];
      });
  untrunc_my =
    with super;
    (untrunc-anthwlock.overrideAttrs (oldAttrs: rec {
      version = "2024-08-14";
      src = fetchFromGitHub {
        owner = "anthwlock";
        repo = "untrunc";
        rev = "13cafedf59369db478af537fb909f0d7fd0eb85f";
        sha256 = "sha256-4GIPj8so7POEwxKZzFBoJTu76XKbGHYmXC/ILeo0dVE=";
      };
      buildInputs = oldAttrs.buildInputs ++ [ cmake ];
      cmakeFlags =  ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    }));
  x11spice =
    with super;
    (x11spice.overrideAttrs (oldAttrs: rec {
      version = "2022-07-05";
      src = fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "spice";
        repo = "x11spice";
        rev = "9d6965c774eb3b83786276e333014ff78d8e2f15";
        sha256 = "sha256-HNzEBuejIxA8UvSqwpvByPSG4trki9xLCDBCmb50b4k=";
      };
    }));
  wget2_my =
    with super;
    (wget2.override {
      #  openssl = libressl;
    }).overrideAttrs
      (old: rec {
        version = "2023-01-22";
        src = fetchGit {
          url = "https://gitlab.com/gnuwget/wget2";
          ref = "master";
        };
      });
}
