{ inputs }:
self: super: {
  intel-zero =
    with super;
    stdenv.mkDerivation {
      name = "intel-level-zero";
      version = "git";
      src = fetchGit {
        url = "https://github.com/oneapi-src/level-zero";
        ref = "master";
        #          rev = "205bdb828b70439482d96dc398727b975523866c";
      };
      nativeBuildInputs = [
        cmake
        pkg-config
      ];
      buildInputs = with xorg; [
        self.libva_my
        libdrm
        libpciaccess
        libX11
        libxcb
        self.intel-gmmlib
      ];
      # cmakeFlags = [
      #   "-DBUILD_RUNTIME=ON"
      #   "-DBUILD_TOOLS=ON"
      # ];
    };
}
