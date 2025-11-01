{ inputs }:
# let
#   pkgsmaster = import inputs.nixpkgsmaster {};
# in
self: super: {
  mpv_my =
    with super;
    (mpv-unwrapped.override {
      archiveSupport = true;
      bluraySupport = true;
      bs2bSupport = true;
      cmsSupport = true;
      cacaSupport = false;
      drmSupport = true;
      vulkanSupport = true;
      waylandSupport = true;
      cddaSupport = true;
      pulseSupport = false;
      openalSupport = false;
      vaapiSupport = true;
      vapoursynthSupport = false;
      vdpauSupport = false;
      #          xineramaSupport = true;
      #          xvSupport = true;
      #          screenSaverSupport = true;
      pipewireSupport = true;
      ffmpeg = self.ffmpeg_my;
      libva = self.libva_my;
      shaderc = self.shaderc_my;
      libass = libass.overrideAttrs (old: rec {
        src = fetchGit {
          url = "https://github.com/libass/libass";
          ref = "master";
        };
        nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook ];
      });
      libplacebo = self.libplacebo_my;
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/mpv-player/mpv";
          ref = "master";
          #              rev = "c50f536bd1ac1f8154d2b1dcaccd25ab150b414a";
        };
        buildInputs = old.buildInputs ++ [
          xorg.libXpresent
          zlib
          lcms2
          libuchardet
          libarchive
          xorg.libX11
          xorg.libXext
          libGLU
          libGL
          xorg.libXxf86vm
          xorg.libXrandr
          xorg.libXScrnSaver
          xorg.libXinerama
          pipewire
        ];
        postPatch = lib.concatStringsSep "\n" [
          ''
            pushd TOOLS 
            mv mpv_identify.sh mpv_identify 
            patchShebangs *.py *.sh 
            mv mpv_identify mpv_identify.sh 
            popd 
          ''
        ];
        patches = [ ];
        mesonFlags =
        #old.mesonFlags ++
        [
            (lib.mesonOption "default_library" "shared") 
    (lib.mesonBool "libmpv" true) 
    (lib.mesonEnable "manpage-build" true) 
    (lib.mesonEnable "cdda" true) 
    (lib.mesonEnable "dvbin" true) 
    (lib.mesonEnable "dvdnav" true) 
    (lib.mesonEnable "openal" false) 
          (lib.mesonOption "cuda-hwaccel" "disabled")
          (lib.mesonOption "cuda-interop" "disabled")
        ];
        outputs = [
          "out"
          "man"
        ];
      });
}
