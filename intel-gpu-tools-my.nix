{ inputs }:
self: super: {
  intel-gpu-tools_my =
    with super;
    intel-gpu-tools.overrideAttrs (old: rec {
      version = "git";
      src = fetchGit {
        url = "https://gitlab.freedesktop.org/drm/igt-gpu-tools";
        ref = "master";
      };
      doCheck = false;
      patches = [ ];
      preConfigure = "";
      mesonFlags = [
        "-Dtestplan=disabled"
      ];
    });
}
