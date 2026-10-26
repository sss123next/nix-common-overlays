{ inputs }:
self: super:
let
  inherit (super) lib clangStdenv;

  # wx должен совпадать с wxinspector.nix (иначе в одной ссылке два wx).
  # Версия прибита к 3.3.3.1 (как в crealityprint-git.nix): в 3.3.4 у
  # wxGridCellChoiceEditor вместо OnComboCloseUp объявлен DismissEditor, но
  # определения в libwx_gtk3u_core нет → «undefined reference» на линковке
  # (поэтому вариант nixpkgs 4361ae4eb с substituteInPlace сюда не подходит).
  wxGTK' =
    (super.wxwidgets_3_3.override {
      withPrivateFonts = true;
      withWebKit = true;
      withEGL = true;
    }).overrideAttrs
      (old: {
        version = "3.3.3.1";
        src = super.fetchFromGitHub {
          owner = "wxWidgets";
          repo = "wxWidgets";
          tag = "v3.3.3.1";
          fetchSubmodules = true;
          hash = "sha256-gB+mEk8rHpB4z1m8RWJSV+upKzLt7pZtlviS2g03EHY=";
        };
        buildInputs = old.buildInputs ++ [ super.libsecret ];
        configureFlags = old.configureFlags ++ [
          # Disable noisy debug dialogs
          "--enable-debug=no"
          "--enable-secretstore"
        ];
      });

  boost' = super.boost186.override {
    enableShared = true;
    enableStatic = false;
    extraFeatures = [
      "log"
      "thread"
      "filesystem"
    ];
  };

  withSystemd = clangStdenv.hostPlatform.isLinux;
  withNvidiaGLWorkaround = false;
in
# Собираем clang'ом и на Linux: GCC на этой кодовой базе съедает безумный
# объём памяти (OOM на 32GB с --cores 16, проходит на clang).
# Тело оверлея — литерал атрибута: вызов super.* на верхнем уровне
# (вне значения атрибута) даёт infinite recursion при сборке fixed-point.
{
    orca-slicer-git = clangStdenv.mkDerivation (finalAttrs: {
      pname = "orca-slicer-git";
      # Версия из version.inc (SoftFever_VERSION), git-суффикс пинится здесь:
      # find_package(Git) в main больше не используется.
      version = "2.5.0-dev-unstable-2026-10-26";
    
      src = super.fetchFromGitHub {
        owner = "OrcaSlicer";
        repo = "OrcaSlicer";
        rev = "63048e38587eb1e5ea3f05d0853a93976f58fd8a";
        hash = "sha256-c9nVYL08JSZnfGtfQGI7dKiGeTU+dQCmTEXBN89kgKw=";
      };
    
      __structuredAttrs = true;
      strictDeps = true;
    
      nativeBuildInputs = [
        super.cmake
        super.pkg-config
        super.wrapGAppsHook3
        wxGTK'
        # msgfmt для scripts/run_gettext.sh (postBuild)
        super.gettext
        # -DORCA_BUNDLED_UV_EXECUTABLE: без этого configure качает uv из сети.
        super.uv
      ];
    
      buildInputs = [
        super.binutils
        boost'
        boost'.dev
        super.assimp
        super.cereal
        # OrcaSlicer master требует CGAL >= 6.2 (v2.4.2 хватало cgal_5).
        super.cgal
        super.curl
        super.dbus
        super.draco
        super.eigen_5
        super.expat
        super.ffmpeg
        super.glew
        super.glfw
        super.glib
        super.glib-networking
        super.gmp
        super.gst_all_1.gstreamer
        super.gst_all_1.gst-plugins-base
        super.gst_all_1.gst-plugins-bad
        (super.gst_all_1.gst-plugins-good.override { gtkSupport = true; })
        super.gtk3
        super.hicolor-icon-theme
        # WebRTC-транспорт GUI (камеры): find_package(LibDataChannel CONFIG)
        super.libdatachannel
        super.libsecret
        super.libpng
        super.mpfr
        super.nlopt
        # OCCT >= 7.8 с TKDESTEP/TKDE/TKFillet/TKOffset/TKBool (CAD-ядро).
        # OCCT 8.0.1 (пин upstream): >= 7.8 c TKDESTEP/TKDE/TKFillet/TKOffset/TKBool.
        self.opencascade-occt_8
        super.openvdb
        super.onetbb
        # pybind11-embed линкуется в GUI (vendored pybind11 в deps_src/pybind11),
        # сам интерпретатор — системный python3_12 из nixpkgs.
        super.python312
        # Решатель геометрических ограничений Design/CAD-таба: find_package(SLVS)
        self.slvs
        # Инспектор wx-виджетов: find_package(wxInspector)
        self.wxinspector
        super.webkitgtk_4_1
        wxGTK'
        super.libx11
        super.opencv.cxxdev
        super.libnoise
      ]
      ++ lib.optionals withSystemd [ super.systemdLibs ];
    
      # Исправления, которые upstream ещё не слил / специфичны для nix.
      patches = [
        # opencv_world у nixpkgs не собирается — линкуем конкретные модули.
        ./orca-slicer-git/dont-link-opencv-world.patch
        # Не копируем «bundled» libpython из несуществующего deps-префикса:
        # рантайм ищет его через ORCA_BUNDLED_PYTHON_ROOT (см. postPatch).
        ./orca-slicer-git/skip-bundled-python-copy.patch
        # configure-time стейджинг ffmpeg-.so из deps-префикса (AppImage-флоу) —
        # в nix ffmpeg приходит через rpath, копировать нечего.
        ./orca-slicer-git/skip-ffmpeg-sos-staging.patch
        # Убираем небезопасный ilmbase из FindOpenVDB (PrusaSlicer PR 14207).
        ./orca-slicer-git/no-ilmbase.patch
        # Настраиваемая проверка обновлений (PR 7650, ещё не влит в main).
        # Локальная копия: контекст hunk'а в GUI_App.cpp обновлён под main.
        ./orca-slicer-git/pr-7650-configurable-update-check.patch
      ];
    
      postPatch = ''
        # CMake ищет «bundled» Python 3.12.13 в ''${CMAKE_PREFIX_PATH}/libpython —
        # в nix-сборке этого каталога нет. Указываем на системный python312:
        # он же уходит в GeneratedConfig.hpp (ORCA_BUNDLED_PYTHON_ROOT) и
        # рантаймом используется как python home (lib/python3.12/encodings).
        substituteInPlace CMakeLists.txt \
          --replace-fail 'set(_bundled_python_root "''${CMAKE_PREFIX_PATH}/libpython")' \
                         'set(_bundled_python_root "${super.python312}")'
    
        # nixpkgs python3_12 — 3.12.15, а не 3.12.13: снимаем EXACT,
        # оставляя нижнюю границу 3.12.x.
        substituteInPlace CMakeLists.txt \
          --replace-fail ' EXACT REQUIRED' ' REQUIRED'
    
        # set(OpenCASCADE_DIR "''${CMAKE_PREFIX_PATH}/lib/cmake/occt") указывает на
        # deps-супербилд, а в nixpkgs конфиг OCCT лежит в lib/cmake/opencascade.
        # Пусть find_package ищет сам (через NIXPKGS_CMAKE_PREFIX_PATH).
        sed -i '/set(OpenCASCADE_DIR/d' src/libslic3r/CMakeLists.txt
    
        # nixpkgs libnoise ставит заголовки как include/noise/..., а не
        # include/libnoise/...; LIBNOISE_INCLUDE_DIR при этом указывает на include.
        sed -i \
          -e 's|<libnoise/module/modulebase.h>|<noise/module/modulebase.h>|' \
          -e 's|"libnoise/noise.h"|"noise/noise.h"|' \
          src/libslic3r/Feature/FuzzySkin/FuzzySkin.cpp

        # GUI_ObjectTable.cpp вызывает wxGridCellChoiceEditor::OnComboCloseUp —
        # он есть только в wx <= 3.3.3.1, поэтому wx прибита выше (см. wxGTK'),
        # а не патчится на DismissEditor(), как делает nixpkgs для 3.3.4.
      '';
    
      cmakeFlags = [
        (lib.cmakeBool "SLIC3R_STATIC" false)
        (lib.cmakeBool "SLIC3R_FHS" true)
        (lib.cmakeFeature "SLIC3R_GTK" "3")
        (lib.cmakeBool "BBL_RELEASE_TO_PUBLIC" true)
        (lib.cmakeBool "BBL_INTERNAL_TESTING" false)
        # Опция в main называется BUILD_TESTS (SLIC3R_BUILD_TESTS больше нет).
        (lib.cmakeBool "BUILD_TESTS" false)
        # Design/CAD-таб: OCCT-ядро + SLVS + wxInspector.
        (lib.cmakeBool "SLIC3R_CAD" true)
        (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DGL_SILENCE_DEPRECATION")
        (lib.cmakeFeature "CMAKE_EXE_LINKER_FLAGS" "-Wl,--no-as-needed")
        (lib.cmakeBool "ORCA_VERSION_CHECK_DEFAULT" false)
        (lib.cmakeFeature "LIBNOISE_INCLUDE_DIR" "${super.libnoise}/include")
        (lib.cmakeFeature "LIBNOISE_LIBRARY_RELEASE" "${super.libnoise}/lib/libnoise-static.a")
        # uv: configure иначе качает закреплённый бинарник file(DOWNLOAD ...),
        # что в sandbox недоступно.
        (lib.cmakeFeature "ORCA_BUNDLED_UV_EXECUTABLE" "${super.uv}/bin/uv")
        "-Wno-dev"
      ];
    
      env = {
        NLOPT = super.nlopt;
    
        NIX_CFLAGS_COMPILE = toString [
          "-Wno-ignored-attributes"
          "-I${super.opencv.out}/include/opencv4"
          "-Wno-error=incompatible-pointer-types"
          "-Wno-error=format-security"
          "-Wno-uninitialized"
          "-Wno-unused-result"
          "-Wno-deprecated-declarations"
          "-Wno-format-overflow"
          "-DBOOST_ALLOW_DEPRECATED_HEADERS"
          "-DBOOST_MATH_DISABLE_STD_FPCLASSIFY"
          "-DBOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS"
          "-DBOOST_MATH_DISABLE_FLOAT128"
          "-DBOOST_MATH_NO_QUAD_SUPPORT"
          "-DBOOST_MATH_MAX_FLOAT128_DIGITS=0"
          "-DBOOST_CSTDFLOAT_NO_LIBQUADMATH_SUPPORT"
          "-DBOOST_MATH_DISABLE_FLOAT128_BUILTIN_FPCLASSIFY"
        ];
    
        NIX_LDFLAGS = toString [
          (lib.optionalString withSystemd "-ludev")
          "-L${boost'}/lib"
          "-lboost_log"
          "-lboost_log_setup"
        ];
      };
    
      # Generate translation files
      postBuild = "( cd .. && ./scripts/run_gettext.sh )";
    
      preFixup = ''
        gappsWrapperArgs+=(
          --prefix LD_LIBRARY_PATH : "$out/lib:${
            lib.makeLibraryPath [
              super.glew
            ]
          }"
          --set WEBKIT_DISABLE_COMPOSITING_MODE 1
          ${lib.optionalString withNvidiaGLWorkaround ''
            --set __GLX_VENDOR_LIBRARY_NAME mesa
            --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json
            --set MESA_LOADER_DRIVER_OVERRIDE zink
            --set GALLIUM_DRIVER zink
            --set WEBKIT_DISABLE_DMABUF_RENDERER 1
          ''}
        )
      '';
    
      postInstall = ''
        rm -f $out/LICENSE.txt
      '';
    
      separateDebugInfo = true;
    
      meta = {
        description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.), git master build";
        homepage = "https://github.com/OrcaSlicer/OrcaSlicer";
        changelog = "https://github.com/OrcaSlicer/OrcaSlicer/commits/master/";
        license = lib.licenses.agpl3Only;
        maintainers = with lib.maintainers; [ ];
        mainProgram = "orca-slicer";
        platforms = lib.platforms.linux;
      };
    });
}
