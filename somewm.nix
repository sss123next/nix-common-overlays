{ inputs }:
self: super:
let
  # SomeWM — AwesomeWM, портированный на Wayland (wlroots 0.20, LuaJIT + lgi).
  # Апстримский package.nix спроектирован под внешний callPackage (см.
  # docs/howtonix.md): все зависимости/флаги/обёртки (luaEnv с lgi+ldbus,
  # GI_TYPELIB_PATH, -Dsystemd=disabled) уже там и живут в одном месте —
  # дублировать их здесь не нужно, достаточно подложить свой src и версию
  # (у апстрима захардкожены `src = ./.` и `version = "dev"`).
  # Свой flake апстрима не используем: он тянет второй закреплённый nixpkgs
  # (18b9261c/nixos-unstable) → дубль glibc/cairo/gtk в closure.
  src = builtins.fetchTarball {
    url = "https://github.com/trip-zip/somewm/archive/refs/tags/v2.0.0.tar.gz";
    sha256 = "1v6f3qglg1vbm7h1ynhhnzyxr93g89rmsskx8mgyfp1vfskg155q";
  };
in
{
  somewm = (super.callPackage (src + "/package.nix") { }).overrideAttrs (old: {
    # src у апстрима — `./.` (т.е. наш fetchTarball), менять нечего, поэтому
    # правим только версию: у апстрима она захардкожена как "dev".
    __intentionallyOverridingVersion = true;
    version = "2.0.0";

    meta = old.meta // {
      # meson.build: license: 'GPL-3.0-or-later'
      license = super.lib.licenses.gpl3Plus;
      changelog = "https://github.com/trip-zip/somewm/releases";
    };
  });
}
