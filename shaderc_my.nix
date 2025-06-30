{ inputs }:
self: super: {
  shaderc_my =
    with super;
    let
      glslang = fetchGit {
        url = "https://github.com/KhronosGroup/glslang";
        ref = "main";
        rev = "963588074b26326ff0426c8953c1235213309bdb";
      };
      spirv-tools = fetchGit {
        url = "https://github.com/KhronosGroup/SPIRV-Tools";
        ref = "main";
        rev = "66fe610946a6d98169f8ebe9ca483f64c4009fa5";
      };
      spirv-headers = fetchGit {
        url = "https://github.com/KhronosGroup/SPIRV-Headers";
        ref = "main";
        rev = "c9aad99f9276817f18f72a4696239237c83cb775";
      };
    in
    stdenv.mkDerivation {
      pname = "shaderc";
      version = "git";

      outputs = [
        "out"
        "lib"
        "bin"
        "dev"
        "static"
      ];
      src = fetchGit {
        url = "https://github.com/google/shaderc";
        ref = "main";
        rev = "3362e24c42ab5bf7ad32c0fec64b0a0ddeb2fda1";
      };

      postPatch = ''
        cp -r --no-preserve=mode ${glslang} third_party/glslang
        cp -r --no-preserve=mode ${spirv-tools} third_party/spirv-tools
        ln -s ${spirv-headers} third_party/spirv-tools/external/spirv-headers
        patchShebangs --build utils/
      '';

      nativeBuildInputs =
        [
          cmake
          python3
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [ cctools ]
        ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
          autoSignDarwinBinariesHook
        ];

      postInstall = ''
        moveToOutput "lib/*.a" $static
      '';

      cmakeFlags = [ "-DSHADERC_SKIP_TESTS=ON" ];

      # Fix the paths in .pc, even though it's unclear if all these .pc are really useful.
      postFixup = ''
        substituteInPlace "$dev"/lib/pkgconfig/*.pc \
          --replace '=''${prefix}//' '=/' \
          --replace "$dev/$dev/" "$dev/"
      '';

      meta = with lib; {
        inherit (src.meta) homepage;
        description = "Collection of tools, libraries and tests for shader compilation";
        platforms = platforms.all;
        license = [ licenses.asl20 ];
      };
    };
}
