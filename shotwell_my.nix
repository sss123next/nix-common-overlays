{ inputs }:
  let
#    oldpkgs = import inputs.nixpkgs2411 { };
  in
self: super: {
  shotwell_my =
    with super;
    (shotwell.overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://gitlab.gnome.org/GNOME/shotwell";
        ref = "master";
        #                rev = "59a38897bf28cba9ef787840dac72e4647510bbb";
      };
#      nativeBuildInputs = old.nativeBuildInputs ++ [ cmake pkg-config ];
      buildInputs = [
        gtk4
        libexif
        libgphoto2
        libwebp
        libsoup_3
        libxml2
        sqlite
        webkitgtk_6_0
        gst_all_1.gstreamer
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        libgee
        libgudev
        gexiv2
        gsettings-desktop-schemas
        libraw
        json-glib
        glib
        glib-networking
        gdk-pixbuf
        librsvg
        librest
        gcr_4
        adwaita-icon-theme
        libsecret
        libportal-gtk4
      ];
      #              buildInputs = old.buildInputs ++ [ libportal libportal-gtk3 llvmPackages_15.openmp gtk4 ];
      postPatch = '''';
    })).override
      {
        #stdenv = llvmPackages_15.stdenv;
      };
}
