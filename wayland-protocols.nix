{ inputs }:
self: super: {
  wayland-protocols =
    with super;
    (wayland-protocols.override { }).overrideAttrs (old: rec {
      version = "1.45";
      src = fetchurl {
        url = "https://gitlab.freedesktop.org/wayland/${old.pname}/-/releases/${version}/downloads/${old.pname}-${version}.tar.xz";
#        hash = "sha256-J4a2sbeZZeMT8sKJwSB1ue1wDUGESBDFGv2hDuMpV2s=";
        hash = "sha256-TSsqnj4JnQF9yBB78cM00nu4fZ5K/xmgyNhW0XzUHvA=";
      };
    });
}
