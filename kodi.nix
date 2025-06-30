{ inputs }:
self: super: {
  kodi_my =
    with super;
    kodi.withPackages (
      kodiPkgs: with kodiPkgs; [
        a4ksubtitles
        chardet
        controller-topology-project
        defusedxml
        iagl
        inputstream-adaptive
        inputstream-ffmpegdirect
        inputstream-rtmp
        joystick
        keymap
        libretro
        libretro-genplus
        libretro-mgba
        libretro-nestopia
        libretro-snes9x
        pvr-iptvsimple
        steam-controller
        vfs-libarchive
      ]
    );
}
