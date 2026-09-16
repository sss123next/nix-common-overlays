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

      # --- Deprecated/removed options for this ffmpeg snapshot ---
      withCelt = false; # configure: no libcelt option
      withLcevcdec = false; # not needed
      withShaderc = false; # configure: no libshaderc option

      # --- Enabled features ---
      withFullDeps = true;
      withBluray = true;
      withFribidi = true;
      withFreetype = true;
      withFontconfig = true;
      withSvg = true;
      # withPlacebo defaults to true with fullDeps
    }).overrideAttrs
      (oldAttrs: rec {
        version = "2026-09-07-vpl-git";
        src = fetchGit {
          url = "https://git.ffmpeg.org/ffmpeg.git";
          ref = "master";
          rev = "e4ed85ab73406c970c7cc30207f663572f5a4c30";
          allRefs = true;
        };
        configureFlags = lib.filter (f:
          # Removed from configure in this ffmpeg snapshot; nixpkgs still
          # generates them via versionOlder guards that are too broad.
          !(lib.hasInfix "libcelt" f) &&
          !(lib.hasInfix "libshaderc" f)
        ) oldAttrs.configureFlags ++ [
          # Intel VPL hardware acceleration
          "--enable-libvpl"
          # Build optimizations
          "--disable-hardcoded-tables"
          "--enable-lto=thin"
        ];
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ nasm ];
        buildInputs = oldAttrs.buildInputs ++ [
          self.libvpl
        ];
        patches = [ ];
        postPatch = "";
        doCheck = false;
      });
}
