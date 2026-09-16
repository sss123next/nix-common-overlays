{ inputs }:
let
  cmFlag = flag: if flag then "ON" else "OFF";
in
self: super: {
  freerdp_my =
    with self.lib;
    with super;
    with xorg;
    stdenv.mkDerivation rec {
      pname = "freerdp";
      version = "git";

      src = fetchGit {
        url = "https://github.com/FreeRDP/FreeRDP";
        ref = "master";
        #rev = "7b6023b3400658aa7b303997a221814daccd44fc";
        rev = "598746a26bb528c96009bc83c2b1cebd85542bfa";

      };

      doCheck = false;

      postPatch = ''
        export HOME=$TMP

        # skip NIB file generation on darwin
        sed -z 's/NIB file generation.*//' -i client/Mac{,/cli}/CMakeLists.txt

        substituteInPlace "libfreerdp/freerdp.pc.in" \
          --replace "Requires:" "Requires: @WINPR_PKG_CONFIG_FILENAME@"
      ''
      + lib.optionalString (pcsclite != null) ''
        substituteInPlace "winpr/libwinpr/smartcard/smartcard_pcsc.c" \
          --replace "libpcsclite.so" "${lib.getLib pcsclite}/lib/libpcsclite.so"
      '';

      buildInputs = [
        cairo
        faad2
        ffmpeg
        glib
        icu
        libX11
        libXcursor
        libXdamage
        libXdmcp
        libXext
        libXi
        libXinerama
        libXrandr
        libXrender
        libXtst
        libXv
        libjpeg_turbo
        libunwind
        libusb1
        libxkbcommon
        libxkbfile
        openssl
        orc
        pcre2
        zlib
        alsa-lib
        systemd
        krb5
        fuse3
        cjson
      ];

      nativeBuildInputs = [
        cmake
        libxslt
        docbook-xsl-nons
        pkg-config
      ];

      # https://github.com/FreeRDP/FreeRDP/issues/8526#issuecomment-1357134746
      cmakeFlags = [
        "-Wno-dev"
        "-DCMAKE_INSTALL_LIBDIR=lib"
        "-DDOCBOOKXSL_DIR=${docbook-xsl-nons}/xml/xsl/docbook"
      ]
      ++ lib.mapAttrsToList (k: v: "-D${k}=${cmFlag v}") {
        BUILD_TESTING = false; # false is recommended by upstream
        WITH_CAIRO = true;
        WITH_CUPS = false;
        WITH_FAAC = false;
        WITH_FAAD2 = true;
        WITH_JPEG = true;
        WITH_OPENH264 = false;
        WITH_OSS = false;
        WITH_PCSC = false;
        WITH_PULSE = false;
        WITH_SERVER = true;
        WITH_VAAPI = false; # false is recommended by upstream
        WITH_X11 = true;
        WITH_CLIENT_SDL = false;
      };

      meta = with lib; {
        description = "A Remote Desktop Protocol Client";
        longDescription = ''
          FreeRDP is a client-side implementation of the Remote Desktop Protocol (RDP)
          following the Microsoft Open Specifications.
        '';
        homepage = "https://www.freerdp.com/";
        license = licenses.asl20;
        platforms = platforms.unix;
      };
    };
}
