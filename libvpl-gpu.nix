{ inputs }:
self: super: {
  libvpl-gpu =
    with super;
    stdenv.mkDerivation {
      name = "libvpl-gpu";
      version = "git";
      src = fetchGit {
        url = "https://github.com/intel/vpl-gpu-rt";
        ref = "main";
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
        #          self.libvpl
        #          intel-ocl self.intel-media-sdk
      ];
      cmakeFlags = [
        "-DBUILD_RUNTIME=ON"
        "-DBUILD_TOOLS=ON"
      ];
    };
}
