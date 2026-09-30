{ inputs }:
self: super: {
  ffmpeg_my =
    with super;
    # Base: ffmpeg_9-full. nixpkgs keys its configure guards off the package
    # version, and 9.0.x matches the master snapshot pulled in below, so it no
    # longer emits options upstream has already dropped (libcelt/libshaderc).
    # Tracking master still means configure can drop an option any day --
    # preConfigure below removes such flags automatically.
    (ffmpeg_9-full.override {
      # --- Custom library versions from our overlays ---
      libaom = self.libaom_my;
      dav1d = self.dav1d_my;
      libva = self.libva_my;
      libplacebo = self.libplacebo_my;
      # Our fresh oneVPL dispatcher, not nixpkgs'. Passing it explicitly makes
      # this independent of overlay ordering (callPackage would otherwise keep
      # whatever libvpl was resolved at the base package's overlay stage).
      libvpl = self.libvpl;

      # --- Licensing ---
      withUnfree = true;

      # --- NVIDIA — disabled (Intel-only system) ---
      withNvcodec = false; # drops ffnvcodec + nv-codec-headers-12
      withCuvid = false; # follows withNvcodec, set explicitly
      withCuda = false;
      withCudaLLVM = false;
      withNvdec = false;
      withNvenc = false;
      withVdpau = false;
      nv-codec-headers = false;

      # --- Other HW accel — disabled ---
      withMfx = false;
      withAmf = false;
      withOpencl = false;

      # --- Gone from configure in this master snapshot (n9.0+) ---
      withCelt = false;
      withShaderc = false;
      withLcevcdec = false; # not needed

      # --- Enabled features ---
      withFullDeps = true;
      withBluray = true;
      withFribidi = true;
      withFreetype = true;
      withFontconfig = true;
      withSvg = true;
      withVpl = true; # Intel QSV (--enable-libvpl) against self.libvpl above
      # withPlacebo defaults to true with fullDeps
    }).overrideAttrs
      (oldAttrs: rec {
        version = "2026-09-29-vpl-git";
        src = fetchGit {
          url = "https://git.ffmpeg.org/ffmpeg.git";
          ref = "master";
          rev = "ff2059afd90c46d7e1b0f92542b204accb408ffb";
        };
        configureFlags = oldAttrs.configureFlags ++ [
          # Build optimizations (nixpkgs passes --enable-hardcoded-tables;
          # the last flag wins in configure)
          "--disable-hardcoded-tables"
          "--enable-lto=thin"
        ];

        # Self-healing: drop --enable/--disable flags this snapshot doesn't
        # know. configure aborts with `Unknown option` otherwise. Probing with
        # --help last makes configure die during option parsing, before any
        # compiler check, so the whole probe costs about a second.
        preConfigure = (oldAttrs.preConfigure or "") + ''
          _ffFlags=()
          if declare -p configureFlags 2>/dev/null | grep -q '^declare -a'; then
            _ffFlags=("''${configureFlags[@]}")
          else
            _ffFlags=(''${configureFlags-})
          fi
          _ffN=''${#_ffFlags[@]}
          for ((_ffI = 0; _ffI < _ffN; _ffI++)); do
            if _ffOut=$(./configure "''${_ffFlags[@]}" --help 2>&1); then
              break
            fi
            _ffBad=$(printf '%s\n' "$_ffOut" | sed -n 's/^Unknown option "\(.*\)"\.$/\1/p' | head -n1)
            if [ -z "$_ffBad" ]; then
              echo "ffmpeg_my: configure probe failed for another reason, keeping flags:"
              printf '%s\n' "$_ffOut" | tail -n 5
              break
            fi
            echo "ffmpeg_my: dropping configure flag unknown to this snapshot: $_ffBad"
            _ffKept=()
            for _ffF in "''${_ffFlags[@]}"; do
              [ "$_ffF" = "$_ffBad" ] || _ffKept+=("$_ffF")
            done
            _ffFlags=("''${_ffKept[@]}")
          done
          if declare -p configureFlags 2>/dev/null | grep -q '^declare -a'; then
            configureFlags=("''${_ffFlags[@]}")
          else
            configureFlags="''${_ffFlags[*]}"
          fi
          echo "ffmpeg_my: configure probe done, using ''${#_ffFlags[@]} flags"
        '';

        patches = [ ];
        postPatch = "";
        doCheck = false;
      });
}
