{ inputs }:
self: super: {
  wireplumber =
    with super;
    wireplumber.overrideAttrs (oldAttrs: rec {
      version = "2025-08-15-git";
      src = fetchGit {
        url = "https://gitlab.freedesktop.org/pipewire/wireplumber";
        ref = "master";
        rev = "30e8440b256d04ddd4bfaeb2758d4d5189789952";
      };
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ wrapGAppsHook ];
      buildInputs = oldAttrs.buildInputs ++ [ gsettings-desktop-schemas ];
    });
}
