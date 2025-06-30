{ inputs }:
self: super: {
  gimp_my =
    with super;
    (gimp.override { gexiv2 = self.gexiv2_my; }).overrideAttrs (oldAttrs: rec {

    });
}
