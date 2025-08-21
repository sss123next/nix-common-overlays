{ inputs }:
self: super: {
  gthumb_my =
    with super;
    with gsettings-desktop-schemas;
    with xorg;
    (stdenv.mkDerivation {
      name = "gthumb";
      version = "git";
      src = fetchGit {
        url = "https://gitlab.gnome.org/GNOME/gthumb";
        ref = "master";
      };

      nativeBuildInputs = [
        bison
        desktop-file-utils
        flex
        itstool
        meson
        ninja
        pkg-config
        python3
        wrapGAppsHook
      ];

      buildInputs = [
        clutter-gtk
#        self.exiv2_my
        glib
        adwaita-icon-theme
        gsettings-desktop-schemas
        gst_all_1.gst-plugins-base
        (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gtk3
        json-glib
        lcms2
        libchamplain
        self.libheif_my
        libjpeg
        libjxl
        self.libraw
        librsvg
        libtiff
        libwebp
        libX11
      ];
      mesonFlags = [
        "-Dlibchamplain=true"
      ];

      postPatch = ''
        chmod +x gthumb/make-gthumb-h.py

        patchShebangs data/gschemas/make-enums.py \
          gthumb/make-gthumb-h.py \
          po/make-potfiles-in.py \
          postinstall.py \
          gthumb/make-authors-tab.py
      '';

      preFixup = ''
        gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
      '';

      passthru = {
        updateScript = gnome.updateScript {
          packageName = pname;
          versionPolicy = "odd-unstable";
        };
      };

      meta = with lib; {
        homepage = "https://gitlab.gnome.org/GNOME/gthumb";
        description = "Image browser and viewer for GNOME";
        mainProgram = "gthumb";
        platforms = platforms.linux;
        license = licenses.gpl2Plus;
        maintainers = [ maintainers.mimame ];
      };

    });

}
