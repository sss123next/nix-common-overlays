# dovecot + Pigeonhole (Sieve) in ONE derivation.
#
# Why a single derivation:
#   dovecot bakes the default `mail_plugin_dir` into libdovecot.so as
#   $out/lib/dovecot/modules. Upstream nixpkgs ships pigeonhole as a separate
#   package, so its .so files live in a *different* store path. On NixOS the
#   module papers over this by pointing mail_plugin_dir at
#   /run/current-system/sw/lib/dovecot/modules (a symlink farm that only
#   exists on NixOS and only for environment.systemPackages).
#
#   Consequences elsewhere (non-NixOS host, `nix profile install`, home-manager):
#   the compiled default points at dovecot's own moduledir, which has no sieve
#   .so -> `mail_plugins = sieve` silently does nothing.
#
#   A symlinkJoin of the two packages cannot fix this either: the merged output
#   would be a new store path, but the compiled string still points at the old
#   dovecot, while pigeonhole's RUNPATH points at that same old dovecot -> the
#   process would end up with two libdovecot instances and the plugin would
#   register into the wrong one.
#
#   So: rebuild dovecot and build pigeonhole *inside* that same build, against
#   $out and into $out. One store path, one libdovecot, and the compiled-in
#   default mail_plugin_dir already contains sieve. Works with a stock config
#   on any host.
#
# Usage: pkgs.dovecot_sieve (drop-in for pkgs.dovecot; also usable as
# services.dovecot2.package -- its passthru.dovecot_pigeonhole points at
# itself, so sievec resolves from the same build).
{ inputs }:
self: super:
with super;
let
  # Sources/patches reused from nixpkgs' pigeonhole: only .src and .patches
  # are read, the separate dovecot_pigeonhole derivation is never built, and
  # its version stays in sync with dovecot automatically.
  pigeonholeSrc = dovecot_pigeonhole.src;
  pigeonholePatches = dovecot_pigeonhole.patches or [ ];

  # Pigeonhole must be configured exactly like dovecot was (LDAP-wise).
  withLDAP = lib.elem "--with-ldap" dovecot.configureFlags;

  dovecotSieve = dovecot.overrideAttrs (
    old:
    {
      pname = "dovecot-sieve";

      # settings-history.py is invoked as `$(PYTHON) ...` while building the
      # settings plugin; dovecot itself does not need python.
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ python3 ];

      # ---- upstream test that does not survive this build sandbox ----
      # src/lib-http/test-http-server-errors hangs until its hard 10s
      # watchdog (SERVER_MAX_TIMEOUT_MSECS, "SERVER: Fatal: Server timed
      # out") in this environment. It is not caused by this overlay: stock
      # pkgs.dovecot fails byte-for-byte identically on the local builders
      # (it only succeeds when substituted from the binary cache), and the
      # failure also happens with a serial `make check`. Skip just this one
      # test binary (its "response ostream disconnect" / "bad payload"
      # subtests); the remaining ~5900 dovecot tests keep running.
      preCheck =
        (old.preCheck or "")
        + ''
          substituteInPlace src/lib-http/Makefile \
            --replace-fail 'TESTS = $(am__EXEEXT_1)' \
                           'TESTS = $(filter-out test-http-server-errors$(EXEEXT),$(am__EXEEXT_1))'
        '';

      passthru = (old.passthru or { }) // {
        # our $out ships sievec/sieve-* too -> keep the NixOS module's
        # `getExe' pkg.passthru.dovecot_pigeonhole "sievec"` on one build.
        dovecot_pigeonhole = dovecotSieve;
      };

      # old.postInstall does the DESTDIR flattening, so at this point
      # $out/lib/dovecot/dovecot-config exists and pigeonhole can be built
      # against it.
      postInstall =
        (old.postInstall or "")
        + ''

          # ---- Pigeonhole: build against this $out, install into this $out ----
          cp -r ${pigeonholeSrc} ./pigeonhole-src
          chmod -R u+w ./pigeonhole-src
          pushd ./pigeonhole-src > /dev/null

          ${lib.concatMapStrings (p: "patch -p1 < ${p}\n") pigeonholePatches}

          patchShebangs src/plugins/settings/settings-get.pl

          substituteInPlace src/managesieve/managesieve-settings.c \
            --replace-fail '.executable = "managesieve"' \
                           ".executable = \"$out/libexec/dovecot/managesieve\""
          substituteInPlace src/managesieve-login/managesieve-login-settings.c \
            --replace-fail '.executable = "managesieve-login"' \
                           ".executable = \"$out/libexec/dovecot/managesieve-login\""

          # --without-dovecot-install-dirs keeps pigeonhole's libs/docs under
          # their own subdirs of $out (no collisions with dovecot's files),
          # while --with-moduledir points straight at dovecot's moduledir so
          # the modules merge into the compiled-in default.
          #
          # dovecot is not a buildInput here (it IS $out), so the rpath to its
          # libs has to be explicit: otherwise libdovecot-sieve.so cannot
          # resolve libdovecot.so.0 / libdovecot-storage.so.0 / ldap at runtime.
          LDFLAGS="-Wl,-rpath,$out/lib/dovecot" ./configure \
            --prefix=$out \
            --with-dovecot=$out/lib/dovecot \
            --with-moduledir=$out/lib/dovecot/modules \
            --without-dovecot-install-dirs \
            ${lib.optionalString withLDAP "--with-ldap"}

          make -j"$NIX_BUILD_CORES" \
            PYTHON=${python3}/bin/python3 \
            SETTINGS_HISTORY_PY=$out/libexec/dovecot/settings-history.py

          make install

          popd > /dev/null

          # sanity: sieve must be reachable from dovecot's own moduledir
          test -f "$out/lib/dovecot/modules/lib90_sieve_plugin.so"
          test -x "$out/libexec/dovecot/managesieve"
        '';

      meta = (old.meta or { }) // {
        description = "Dovecot IMAP/POP3/SMTP server with the Pigeonhole (Sieve) plugin built in";
      };
    }
  );
in
{
  dovecot_sieve = dovecotSieve;
}
