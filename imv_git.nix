{ inputs }:
self: super:
{
  # imv @ git master + mouse-binds patch
  # (patches/imv-mouse-binds.patch: mouse buttons and the scroll wheel become
  #  bindable in [binds]: Left/Middle/Right/Side/Extra/Forward/Back and
  #  WheelUp/WheelDown/WheelLeft/WheelRight; unbound wheel keeps zooming).
  # NB: still no `delete` command upstream; keep `exec rm "$imv_current_file"; close`.
  # rev pinned: bump with  nix-prefetch-git https://git.sr.ht/~exec64/imv
  imv_git =
    with super;
    imv.overrideAttrs (old: rec {
      version = "7dc0dda-git";
      src = fetchGit {
        url = "https://git.sr.ht/~exec64/imv";
        ref = "master";
        rev = "7dc0ddad88dcda466067028bea319216e40d4cbe";
      };
      patches = [ ./patches/imv-mouse-binds.patch ];
      # master's meson.build unconditionally needs wayland-scanner
      nativeBuildInputs = old.nativeBuildInputs ++ [ wayland-scanner ];
      # master gained an lcms2 dependency (ICC profiles)
      buildInputs = old.buildInputs ++ [ lcms2 ];
      # report our pinned rev as the version (upstream derives it via
      # `git describe`, which yields nothing in the sandbox; `git` is
      # deliberately not in nativeBuildInputs so meson keeps this value,
      # satisfying versionCheckHook)
      postPatch = ''
        substituteInPlace meson.build --replace-fail "version: '5.0.1'" "version: '${version}'"
      '';
    });
}
