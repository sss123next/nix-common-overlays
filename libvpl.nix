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
        rev = "674d015bcb294bc39fa276e99a652ea045423e82";
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
