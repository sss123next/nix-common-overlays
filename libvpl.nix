{ inputs }:
self: super: {
  libvpl =
    with super;
    stdenv.mkDerivation {
      name = "libvpl";
      version = "git";
      src = fetchGit {
        url = "https://github.com/intel/libvpl";
        ref = "main";
        #                  rev = "e71b1efc1263ae216569f62d018033ab5a850e00";
      };
      nativeBuildInputs = [
        cmake
        pkg-config
      ];
      buildInputs = with xorg; [
        libva
        libdrm
        libpciaccess
        libX11
        libxcb
        #self.libvpl-gpu
      ];
      cmakeFlags = [
        "-DBUILD_TOOLS=ON"
        "-DBUILD_DISPATCHER=ON"
        "-DBUILD_PREVIEW=ON"
        "-DBUILD_DISPATCHER_ONEVPL_EXPERIMENTAL=ON"
        "-DBUILD_TOOLS_ONEVPL_EXPERIMENTAL=ON"
      ];
    };
}
