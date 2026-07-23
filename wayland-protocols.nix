{ inputs }:
self: super: {
  wayland-protocols =
    with super;
    (wayland-protocols.override { }).overrideAttrs (old: rec {
      version = "1.49";
      src = fetchurl {
        url = "https://gitlab.freedesktop.org/wayland/${old.pname}/-/releases/${version}/downloads/${old.pname}-${version}.tar.xz";
        hash = "sha256-7EyPdJQtbf96zotM5HZPDvn/YYqTXZdOp37e4q0kCxQ=";
      };
    });
}
