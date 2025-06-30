{ inputs }:
self: super: {
  libheif_my =
    with super;
    (libheif.override { libaom = self.libaom_my; }).overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/strukturag/libheif";
        ref = "master";
                rev = "e0bfb132ab984ad3d7703b5183a9fb336d96f8a0";
       # rev = "3d66463504385ba8b9ab70b0a6d9d7e6d392a4d9";
      };
      nativeBuildInputs = [
        pkg-config
        cmake
      ];
      buildInputs = oldAttrs.buildInputs ++ [
        svt-av1
        self.ffmpeg_my
        shaderc
      ];
      #            outputs = [ "out" "lib" "dev" ];
      cmakeFlags = [
        "-DWITH_DAV1D=1"
        "-DWITH_FFMPEG_DECODER=1"
        "-DWITH_SvtEnc=1"
        "-DENABLE_PARALLEL_TILE_DECODING=1"
        "-DENABLE_MULTITHREADING_SUPPORT=1"
        "-DENABLE_PLUGIN_LOADING=0"
      ];
    });
}
