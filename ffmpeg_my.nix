{ inputs }:
self: super: {
  ffmpeg_my =
    with super;
    with builtins;
    (ffmpeg_8-full.override {
      libaom = self.libaom_my;
      dav1d = self.dav1d_my;
      libva = self.libva_my;
      libplacebo = self.libplacebo_my;
      #      vulkan-headers = nixpkgsmaster.vulkan-headers;
      #      vulkan-loader = nixpkgsmaster.vulkan-loader;
      #      stdenv = llvmPackages_15.stdenv;
      #          withLTO = true;
      withUnfree = true;
      withCuda = false;
      withCudaLLVM = false;
      withNvdec = false;
      withNvenc = false;
      withVdpau = false;
      nv-codec-headers = false;
      withMfx = false;
      withBluray = true;
      withFribidi = true;
      #      withLibplacebo = false;
      withFreetype = true;
      withFontconfig = true;
      withSvg = true;
      withFullDeps = true;
      withShaderc = false;
      withAmf = false;
      withOpencl = false;

      #          withVulkan = false;
      #          opencl-headers = nixpkgsmaster.opencl-headers;
      #          vid-stab = vid-stab.override{stdenv = llvmPackages_15.stdenv;};

      #          stdenv = super.ccacheStdenv;
    }).overrideAttrs
      (oldAttrs: rec {
        version = "2026-09-07-vpl-git";
        src = fetchGit {
          url = "https://git.ffmpeg.org/ffmpeg.git";
          ref = "master";
          rev = "e4ed85ab73406c970c7cc30207f663572f5a4c30";
          allRefs = true;
        };
        configureFlags =
          (lib.lists.remove "--disable-libshaderc"  (lib.lists.remove "--enable-libcelt" (lib.lists.remove "--enable-liblcevc-dec" (lib.lists.remove "--enable-postproc" (
            lib.lists.remove "--enable-avresample" (
              lib.lists.remove "--disable-avresample" oldAttrs.configureFlags
            )
          )))))
          ++ [
            "--enable-libvpl"
            "--disable-hardcoded-tables"
            "--enable-lto=thin"
            "--disable-liblcevc-dec"
          ];
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ nasm ];
        buildInputs = oldAttrs.buildInputs ++ [
          self.libvpl
          shaderc
        ];
        patches = [ ];
        postPatch = "";
        doCheck = false;
      });
}
