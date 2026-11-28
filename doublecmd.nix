# Double Commander — форк derivation из nixpkgs, трекает upstream master
# (rev-pinned snapshot, 1.3.0 dev после релиза 1.2.11). Исправления:
#   * lua5_4 вместо lua5_5: src/platform/lua.pas использует чистый Lua 5.1 API
#     (lua_objlen / luaL_register / LUA_GLOBALSINDEX / luaL_checkint — все живы
#     и на master), в 5.4+/5.5 эти символы вырезаны — lua-колонки и wfx-плагины
#     на lua5_5 молча не загружаются.
#   * strictDeps — корректный изолированный closure сборки.
# Остальное — как в upstream nixpkgs (derivation оттуда и был взят за основу).
{ inputs }:
self: super:
let
  lua = super.lua5_4;
  widgetset = if super.stdenv.hostPlatform.isDarwin then "cocoa" else "qt5";
in
{
  doublecmd = super.stdenv.mkDerivation (finalAttrs: {
    pname = "doublecmd";
    # upstream master (rev-пinned ниже); .lpi VersionInfo: 1.3 pre-release.
    version = "1.3.0-unstable-2026-11-28";

    src = super.fetchFromGitHub {
      owner = "doublecmd";
      repo = "doublecmd";
      rev = "491ff2dc9acb498dbe77023a2d003d2acd660f14";
      hash = "sha256-PybEbOCxIMDTxXa8mETjn51tXmLCtfTM0m904D1O90M=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      super.fpc
      super.getopt
      super.lazarus
      super.writableTmpDirAsHomeHook
    ]
    ++ super.lib.optional (!super.stdenv.hostPlatform.isDarwin) super.libsForQt5.wrapQtAppsHook;

    buildInputs = [
      super.dbus
      super.glib
      super.libx11
      super.libssh2
    ]
    ++ super.lib.optional (!super.stdenv.hostPlatform.isDarwin) super.libsForQt5.libqtpas;

    env.NIX_LDFLAGS = super.lib.optionalString super.stdenv.hostPlatform.isLinux "--as-needed -rpath ${super.lib.makeLibraryPath finalAttrs.buildInputs}";

    postPatch = ''
      patchShebangs build.sh
      substituteInPlace build.sh \
        --replace-warn '$(which lazbuild)' '"${super.lazarus}/bin/lazbuild --lazarusdir=${super.lazarus}/share/lazarus"'

      # build.sh: --bm=release; в doublecmd.lpi режим называется "Release",
      # lazbuild матчит его регистронезависимо (SameText) — так что всё верно,
      # release = -O2 + -dNIGHTLY_BUILD + внешние DWARF-символы.

      ${
        if super.stdenv.hostPlatform.isDarwin then
          ''
            patchShebangs install/darwin/install.sh

            # Double Commander saves this default into the user's configuration, so use
            # the symlink installed next to the executable instead of a store path.
            substituteInPlace src/platform/lua.pas \
              --replace-fail "LuaDLL = 'liblua5.1.dylib';" "LuaDLL = '%COMMANDER_PATH%/liblua.dylib';"
            substituteInPlace plugins/wfx/ftp/src/sftp/libssh.pas \
              --replace-fail "'libssh2.dylib'" "'${super.lib.getLib super.libssh2}/lib/libssh2.dylib'"
          ''
        else
          ''
            patchShebangs install/linux/install.sh
            substituteInPlace install/linux/install.sh \
              --replace-warn '$DC_INSTALL_PREFIX/usr' '$DC_INSTALL_PREFIX'

            # Same as on Darwin: use the symlink installed next to the executable.
            substituteInPlace src/platform/lua.pas \
              --replace-fail "LuaDLL = 'liblua5.1.so.0';" "LuaDLL = '%COMMANDER_PATH%/liblua.so';"
            substituteInPlace plugins/wfx/ftp/src/sftp/libssh.pas \
              --replace-fail "'libssh2.so.1'" "'${super.lib.getLib super.libssh2}/lib/libssh2.so.1'"
          ''
      }
    '';

    buildPhase = ''
      runHook preBuild

      ./build.sh release ${widgetset}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      ${
        if super.stdenv.hostPlatform.isDarwin then
          ''
            rm -f doublecmd.app/Contents/MacOS/doublecmd
            install/darwin/install.sh "$TMPDIR"
            mkdir -p $out/Applications
            mv "$TMPDIR/doublecmd.app" $out/Applications/
            cd $out/Applications/doublecmd.app/Contents/MacOS
            ln -vs ${super.lib.getLib lua}/lib/liblua.${lua.version}.dylib ./liblua.dylib
            mkdir -p $out/bin
            ln -s $out/Applications/doublecmd.app/Contents/MacOS/doublecmd $out/bin/doublecmd
          ''
        else
          ''
            install/linux/install.sh -I $out
            cd $out/lib64/doublecmd
            ln -vs ${super.lib.getLib lua}/lib/liblua.so.${lua.version}
            ln -vs ./liblua.so.${lua.version} ./liblua.so
            ln -vs ./liblua.so.${lua.version} ./liblua.so.${super.lib.versions.majorMinor lua.version}
          ''
      }

      runHook postInstall
    '';

    meta = with super.lib; {
      homepage = "https://doublecmd.sourceforge.io/";
      description = "Two-panel graphical file manager written in Pascal";
      license = licenses.gpl2Plus;
      mainProgram = "doublecmd";
      maintainers = [ ];
      platforms = platforms.linux ++ platforms.darwin;
    };
  });
}
