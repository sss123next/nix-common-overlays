{ inputs }:
self: super: {
  gexiv2_my =
    with super;
    (gexiv2.override { exiv2 = self.exiv2_my; }).overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://gitlab.gnome.org/GNOME/gexiv2";
        ref = "master";
        rev = "06adc8fb70cb8c77c0cd364195d8251811106ef8";
      };
      #    buildInputs = oldAttrs.buildInputs ++ [ brotli inih ];
      #  doCheck = false;
      mesonFlags = [
        "-Dgtk_doc=true"
        "-Dtests=true"
      ];
    });
}
