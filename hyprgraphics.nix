{ inputs }:
self: super: {
  hyprgraphics =
    with super;
    (hyprgraphics.override { }).overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/hyprwm/hyprgraphics";
        ref = "main";
        #        rev = "0d77b4895ad5f1bb3b0ee43103a5246c58b65591";
      };
      buildInputs = old.buildInputs ++ [ libspng pango cairo ];
    });
}
