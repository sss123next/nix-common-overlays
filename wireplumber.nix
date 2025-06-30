{ inputs }:
self: super: {
  wireplumber =
    with super;
    wireplumber.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://gitlab.freedesktop.org/pipewire/wireplumber";
        ref = "master";
                rev = "7a4d3177550b6b53fe0a49396da5b07f5353daff";
#        rev = "2a5606e43702a3d3a6facdd10d5de685290d6811";
      };
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ wrapGAppsHook ];
      buildInputs = oldAttrs.buildInputs ++ [ gsettings-desktop-schemas ];
    });
}
