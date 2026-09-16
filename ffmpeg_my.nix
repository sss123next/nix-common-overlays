{ inputs }:
self: super: {
  ffmpeg_my =
    with super;
    (ffmpeg_8-full.override {
      # --- Custom library versions from our overlays ---
      libaom = self.libaom_my;
      dav1d = self.dav1d_my;
      libva = self.libva_my;
      libplacebo = self.libplacebo_my;

      # --- Licensing ---
      withUnfree = true;

      # --- NVIDIA — disabled (Intel-only system) ---
      withCuda = false;
      withCudaLLVM = false;
      withNvdec = false;
      withNvenc = false;
      withVdpau = false;
      nv-codec-headers = false;

      # --- Other HW accel — disabled ---
      withMfx = false;
      withAmf = false;
      withOpencl = false;

      # --- Deprecated/removed codecs for ffmpeg 8 ---
      withCelt = false; # removed in ffmpeg 9, unnecessary
      withLcevcdec = false; # not needed

      # --- Enabled features ---
      withFullDeps = true;
      withBluray = true;
      withFribidi = true;
      withFreetype = true;
      withFontconfig = true;
      withSvg = true;
      # withShaderc and withPlacebo default to true with fullDeps
    }).overrideAttrs
      (oldAttrs: rec {
        version = "2026-09-07-vpl-git";
        src = fetchGit {
          url = "https://git.ffmpeg.org/ffmpeg.git";
          ref = "master";
          rev = "e4ed85ab73406c970c7cc30207f663572f5a4c30";
          allRefs = true;
        };
        configureFlags = oldAttrs.configureFlags ++ [
          # Intel VPL hardware acceleration
          "--enable-libvpl"
          # Build optimizations
          "--disable-hardcoded-tables"
          "--enable-lto=thin"
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
