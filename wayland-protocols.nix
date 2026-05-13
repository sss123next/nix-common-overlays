{ inputs }:
self: super: {
  wayland-protocols =
    with super;
    (wayland-protocols.override { }).overrideAttrs (old: rec {
      version = "1.48";
      src = fetchurl {
        url = "https://gitlab.freedesktop.org/wayland/${old.pname}/-/releases/${version}/downloads/${old.pname}-${version}.tar.xz";
        hash = "sha256-OYA2rA62SEmC3b3n/4aEjXUyMfnN7q6YPwa1KUZiWqE=";
      };
    });
}
