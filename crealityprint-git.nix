{ inputs }:
self: super:
let
  inherit (super) lib clangStdenv;

  # wx должен совпадать с wxinspector.nix (иначе в одной ссылке два wx).
  wxGTK' =
    (super.wxwidgets_3_3.override {
      withPrivateFonts = true;
      withWebKit = true;
      withEGL = true;
    }).overrideAttrs
      (old: {
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

  # Alibaba Cloud OSS SDK — загрузка файлов в облако Creality.
  # Версия и патч — из deps/ CrealityPrint (v1.9.2); в nixpkgs пакета нет.
  aliyunOssSdk = super.stdenv.mkDerivation (finalAttrs: {
    pname = "aliyun-oss-cpp-sdk";
    version = "1.9.2";

    src = super.fetchFromGitHub {
      owner = "aliyun";
      repo = "aliyun-oss-cpp-sdk";
      rev = "1.9.2";
      hash = "sha256-XOtOtU4H4oIgNEUBbC06VGpLEuzmPaeRRpCRIUuBL6g=";
    };

    patches = [ ./crealityprint-git/aliyun-oss-1.9.2-fix-slicer-build.patch ];

    # HttpClient.cc в CRLF — патч (git apply у Creality это игнорировал)
    prePatch = ''
      sed -i 's/\r$//' sdk/src/http/HttpClient.cc
    '';

    postPatch = ''
      # cmake 4.x отвергает cmake_minimum_required < 3.5
      sed -i 's/cmake_minimum_required(VERSION 3.1)/cmake_minimum_required(VERSION 3.10)/' CMakeLists.txt
      # свежие компиляторы + -Werror = фейл сборки
      sed -i 's/-Werror//g' CMakeLists.txt
    '';

    nativeBuildInputs = [ super.cmake ];
    buildInputs = [
      super.curl
      super.openssl
    ];

    cmakeFlags = [
      (lib.cmakeBool "BUILD_SAMPLE" false)
      (lib.cmakeBool "BUILD_TESTS" false)
      # static: find_library в CrealityPrint найдёт .a, без visibility-проблем
      (lib.cmakeBool "BUILD_SHARED_LIBS" false)
      (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    ];

    meta = {
      description = "Alibaba Cloud Object Storage Service C++ SDK";
      homepage = "https://github.com/aliyun/aliyun-oss-cpp-sdk";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux;
    };
  });

  # MetaRTC — WebRTC-стек Creality (v1.0.0), нужен для LAN-камеры K1/K2
  # (http://<ip>:8000/call/webrtc_local). Собирается только под Linux.
  # Статические библиотеки libmetartc6.a / libmetartccore6.a + заголовки
  # include/metartc/*. Патчи: FFmpeg 7 const-API (avcodec_find_decoder →
  # const AVCodec*) и avcodec_close() (удалён в FFmpeg 7, маппится на no-op
  # через ffcompat.h — контекст caller всё равно сам освобождает).
  metartc = super.stdenv.mkDerivation (finalAttrs: {
    pname = "metartc";
    version = "1.0.0";

    src = super.fetchzip {
      url = "https://github.com/CrealityOfficial/metartc/archive/refs/tags/v1.0.0.tar.gz";
      hash = "sha256-WMz3xj0dagf51qColVTRRWmUnq4j3NZw6gVcIvZBDaM=";
    };

    patches = [ ./crealityprint-git/metartc/ffmpeg7-const-and-avcodec-close.patch ];

    nativeBuildInputs = [
      super.cmake
      super.pkg-config
      super.ninja
    ];

    buildInputs = [
      super.openssl
      super.ffmpeg
      super.alsa-lib # YangAudioPlayLinux/AecLinux (libmetartc6) тянут asound
    ];

    cmakeFlags = [
      (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
      # cmake 4.x отвергает cmake_minimum_required < 3.5 (в metartc стоит 2.8)
      (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
      # Модуль FindFFmpeg (nixpkgs ffmpeg не шиппит CMake-конфиг, только
      # pkg-config) лежит в этом же store-каталоге.
      (lib.cmakeFeature "CMAKE_MODULE_PATH" "${./crealityprint-git/metartc}")
    ];

    env = {
      # Форс-include ffcompat.h (avcodec_close → no-op; avcodec_find_decoder
      # вернул const AVCodec* — const сами починили патчем). + приглушаем шум
      # legacy-C (GCC 14 сделал incompatible-pointer-types ошибкой по умолч.).
      NIX_CFLAGS_COMPILE = toString [
        "-include ${./crealityprint-git/metartc}/ffcompat.h"
        "-w"
        "-Wno-incompatible-pointer-types"
        "-Wno-implicit-function-declaration"
        "-Wno-int-conversion"
      ];
    };

    meta = {
      description = "MetaRTC WebRTC stack (Creality fork) for LAN camera streaming";
      homepage = "https://github.com/CrealityOfficial/metartc";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  });

  # Ресурсы из официального релизного AppImage 7.3.0.6157.
  #
  # Публичный тег v7.3.0 отстаёт от внутренней ветки, из которой собраны
  # релизные бинарники: в AppImage лежат более свежие profiles/ (новые принтеры
  # Creality mBox и SPARKX i8, ~500 обновлённых пресетов, нормализован регистр
  # имён файлов — на Linux часть профилей не находилась) и пересобранный web/
  # (другие бандлы/CSS). C++ при этом тот же: .mo переводов из AppImage
  # байт-в-байт совпадают с генерируемыми из localization/i18n тега.
  #
  # Берём только profiles/ и web/; i18n собирается из .po в postPatch.
  releaseResources = super.stdenv.mkDerivation {
    pname = "crealityprint-release-resources";
    version = "7.3.0.6157";

    nativeBuildInputs = [
      super.cacert
      super.curl
      super.gnugrep
      super.squashfsTools
    ];

    # FOD: скачиваем AppImage и распаковываем дописанный squashfs-образ.
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-qcfGs12x9XAvb86donG1rBNDesg9anzwYux1Tn4JkcY=";

    buildCommand = ''
      set -eu
      export SSL_CERT_FILE=${super.cacert}/etc/ssl/certs/ca-bundle.crt

      curl -sSL -o app.AppImage \
        "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v7.3.0/CrealityPrint-V7.3.0.6157-x86_64-Release.AppImage"

      # Суперблок squashfs дописан к ELF-рантайму AppImage: перебираем все
      # вхождения магии «hsqs», валидным окажется одно.
      offset=""
      for off in $(grep -abo hsqs app.AppImage | cut -d: -f1); do
        if unsquashfs -o "$off" -s app.AppImage >/dev/null 2>&1; then
          offset="$off"
        fi
      done
      if [ -z "$offset" ]; then
        echo "squashfs superblock not found in AppImage" >&2
        exit 1
      fi

      unsquashfs -o "$offset" -d unpacked app.AppImage resources/profiles resources/web

      mkdir -p "$out"
      cp -r unpacked/resources/profiles "$out/profiles"
      cp -r unpacked/resources/web "$out/web"
    '';

    meta = {
      description = "CrealityPrint 7.3.0.6157 release assets (printer profiles, web UI)";
      license = lib.licenses.agpl3Only;
      platforms = lib.platforms.linux;
    };
  };
in
{
  # MetaRTC экспонируем отдельно — чтобы собирать/тестировать независимо
  # (crealityprint-git тянет его как buildInput).
  metartc = metartc;

  crealityprint-git = clangStdenv.mkDerivation (finalAttrs: {
    pname = "crealityprint-git";
    # rev ниже = тег v7.3.0 (7.3.0.6157 — номер сборки из релизных артефактов).
    version = "7.3.0";

    src = super.fetchFromGitHub {
      owner = "CrealityOfficial";
      repo = "CrealityPrint";
      rev = "59ae8cbb0437dcc7236e27433ecd4aeb52be0244";
      hash = "sha256-JqclLOgjnku5zDXuKFOUhPyz1li3Zd6xSQm5UcfJy6I=";
      fetchSubmodules = false;
    };

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs = [
      super.cmake
      super.gettext
      super.pkg-config
      super.wrapGAppsHook3
      wxGTK'
    ];

    buildInputs = [
      super.binutils
      boost'
      boost'.dev
      super.assimp
      super.cereal
      # CrealityPrint написан под CGAL 5.4 (пин в deps/CGAL/CGAL.cmake),
      # CGAL 6.x сломал property_map()/AABB_traits/extract_boundary_cycles
      super.cgal_5
      super.curl
      super.dbus
      super.draco
      super.eigen
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
      super.libpng
      super.libsecret
      super.usrsctp
      super.mpfr
      super.nlopt
      # OCCT — CAD-ядро для STEP/3D-геометрии (v7.9: модули TKDE* вместо
      # старых TKSTEP*/TKXDESTEP — см. sed в postPatch)
      super.opencascade-occt
      super.openvdb
      super.onetbb
      super.paho-mqtt-cpp
      super.paho-mqtt-c
      super.python312
      super.webkitgtk_4_1
      wxGTK'
      super.libx11
      super.opencv.cxxdev
      super.libnoise
      super.x264 # webrtc_video линкует -lx264 (ffmpeg encoder)
      aliyunOssSdk
      # --- WebRTC-видео (MetaRTC): линковка webrtc_video (src/video) ---
      metartc
      super.srtp # -lsrtp2
      super.alsa-lib # -lasound
      super.opus # -lopus
      super.speexdsp # -lspeexdsp
      super.xz # -llzma
      super.libjpeg # WebRTCDecoder.cpp: jpeglib.h (rgb_to_jpeg)
    ]
    ++ lib.optionals withSystemd [ super.systemdLibs ];

    patches = [
      # OpenVDB: убираем поиск IlmBase (в nixpkgs он часть OpenEXR/Imath)
      ./orca-slicer-git/no-ilmbase.patch
      # Device-page (print_manage) frontend asks C++ for get_lang/is_dark_theme
      # on mount, but PrinterMgrView never answered → vue-i18n stayed en_GB.
      # Плюс диагностика ws-proxy: без неё «молчащее» удаление не отладить.
      ./crealityprint-git/device-page-lang-and-wsproxy-debug.patch
      # (Закрытые Creality-библиотеки CR_TPMS/CR_KM_RECIPE/CR_FILLTENSOR не
      # патчим: в репозитории лежат готовые linux/x86_64-архивы, см. cmakeFlags
      # и NIX_CFLAGS_COMPILE. PahoMqttCpp: nixpkgs собирает shared, а не
      # static — чиним в postPatch)
    ];

    postPatch = ''
      # WebRTC-видео включено (ENABLE_WEBRTC_VIDEO=ON для Linux в src/CMakeLists).
      # MetaRTC упакован (см. metartc в let-блоке) — заголовки пробрасываем
      # через NIX_CFLAGS_COMPILE (-I${metartc}/include/metartc).

      # Закрытые Creality-библиотеки: заголовки и .a берём из deps/ (см.
      # cmakeFlags/NIX_CFLAGS_COMPILE) — TPMS-infill, цветоделение и FillTensor
      # работают как в официальных сборках.

      # set(OpenCASCADE_DIR ''${CMAKE_PREFIX_PATH}/lib/cmake/occt) указывает на
      # deps-супербилд, а в nixpkgs конфиг OCCT лежит в lib/cmake/opencascade.
      # Пусть find_package ищет сам (через NIXPKGS_CMAKE_PREFIX_PATH).
      sed -i '/set(OpenCASCADE_DIR/d' src/libslic3r/CMakeLists.txt

      # nixpkgs OpenCV не собирает opencv_world и не экспортирует opencv::opencv
      # — оба if(TARGET) не срабатывают. Линкуем конкретные модули (как в
      # orca-slicer-git: dont-link-opencv-world.patch).
      substituteInPlace src/libslic3r/CMakeLists.txt \
        --replace-fail \
          'if(TARGET opencv_world)
    target_link_libraries(libslic3r opencv_world)
endif()' \
          'target_link_libraries(libslic3r opencv_core opencv_imgproc opencv_imgcodecs)'

      # OCCT 7.8+: TKSTEP/TKSTEP209/TKSTEPAttr/TKSTEPBase/TKXDESTEP → TKDESTEP
      sed -i \
        -e 's|^    TKXDESTEP$|    TKDESTEP|' \
        -e 's|^    TKSTEP$|    TKDESTEP|' \
        -e '/^    TKSTEP209$/d' \
        -e '/^    TKSTEPAttr$/d' \
        -e '/^    TKSTEPBase$/d' \
        src/libslic3r/CMakeLists.txt

      # nixpkgs libnoise ставит заголовки как include/noise/..., а не
      # include/libnoise/...
      sed -i \
        's|<libnoise/noise.h>|<noise/noise.h>|; s|"libnoise/noise.h"|"noise/noise.h"|' \
        src/libslic3r/Feature/FuzzySkin/FuzzySkin.cpp

      # boost::filesystem::change_extension не существует (только в комментарии
      # path.hpp) — используем метод path::replace_extension
      substituteInPlace src/libslic3r/PrintBase.cpp \
        --replace-fail \
          'filename = boost::filesystem::change_extension(filename, default_ext);' \
          'filename.replace_extension(default_ext);'

      # PahoMqttCpp: nixpkgs собирает shared, а не static
      substituteInPlace src/CMakeLists.txt \
        --replace-fail \
          'PahoMqttCpp::paho-mqttpp3-static' \
          'PahoMqttCpp::paho-mqttpp3'

      # WebRTC/Yang-видео включено: используем настоящий src/video/WebRTCDecoder.h
      # (над MetaRTC, см. metartc в let-блоке). Заголовки metartc/ и jpeglib
      # пробрасываются через NIX_CFLAGS_COMPILE.

      # --- legacy boost::filesystem API (удалён в boost >= 1.86) ---
      sed -i \
        's|#include <boost/filesystem/convenience.hpp>|#include <boost/filesystem.hpp>|; s|boost::filesystem::basename(boost::filesystem::path(path))|boost::filesystem::path(path).stem().string()|' \
        src/slic3r/GUI/RemovableDriveManager.cpp
      sed -i 's|boost::filesystem::extension(path)|path.extension().string()|' \
        src/slic3r/GUI/Plater.cpp
      sed -i 's|fs::extension(file_path)|fs::path(file_path).extension().string()|' \
        src/slic3r/GUI/HttpServer.cpp
      find src -name '*.cpp' -o -name '*.hpp' | xargs sed -i \
        's|copy_option::overwrite_if_exists|copy_options::overwrite_existing|g'

      # boost::uuids::detail::sha1: в boost >= 1.86 digest_type = unsigned char[20]
      # (был uint32_t[5]); восстанавливаем big-endian слова для hex-вывода
      substituteInPlace src/slic3r/GUI/GUI_App.cpp \
        --replace-fail \
          '    unsigned int digest[5] = { 0 };' \
          '    boost::uuids::detail::sha1::digest_type digest = {};' \
        --replace-fail \
          '        oss << digest[i];' \
          '        oss << static_cast<unsigned int>((uint32_t(digest[i * 4]) << 24) | (uint32_t(digest[i * 4 + 1]) << 16) | (uint32_t(digest[i * 4 + 2]) << 8) | uint32_t(digest[i * 4 + 3]));'

      # --- релизные resources (см. releaseResources) ---
      # Профили принтеров/филаментов и web-frontend из официальной сборки новее
      # публичного тега: кладём поверх исходных (одноимённые файлы заменяются,
      # уникальные для тега остаются).
      cp -rf ${releaseResources}/profiles/. resources/profiles/
      cp -rf ${releaseResources}/web/. resources/web/

      # Диагностика device-страницы: JS-ошибки и обмен с ws-proxy уходят в
      # C++ (frontend_log → лог приложения). Временно, до разбора «молчащего»
      # удаления из истории.
      cat ${./crealityprint-git/device-page-diagnostics.html} >> resources/web/deviceMgr/index.html
      # Обход гонки: запрос истории уходит до того, как появился printer-клиент,
      # и больше не повторяется — см. комментарий в файле.
      cat ${./crealityprint-git/device-page-request-history.html} >> resources/web/deviceMgr/index.html

      # --- переводы, как ./run_gettext.sh в официальной сборке ---
      # wx ищет resources/i18n/<lang>/CrealityPrint.mo; без него диалоги
      # остаются на английском (msgid) при русском web-UI.
      for po in localization/i18n/*/CrealityPrint_*.po; do
        lang="$(basename "''${po%.po}")"
        lang="''${lang#*_}"
        mkdir -p "resources/i18n/$lang"
        msgfmt --check-format -o "resources/i18n/$lang/CrealityPrint.mo" "$po"
      done
    '';

    cmakeFlags = [
      # version.inc задаёт CREALITYPRINT_VERSION=7.0.0.0 по умолчанию (реальную
      # версию туда пишет их build-скрипт), из-за чего About показывал 7.0.0.
      (lib.cmakeFeature "CREALITYPRINT_VERSION" "7.3.0.6157")
      # Иначе version.inc ставит "Beta": SHIPPING_LEVEL=1, суффикс "Beta" в
      # About и α-dev ветки в CXCloud/CxAgent. Официальные сборки — Release.
      (lib.cmakeFeature "PROJECT_VERSION_EXTRA" "Release")
      (lib.cmakeBool "SLIC3R_STATIC" false)
      (lib.cmakeBool "SLIC3R_FHS" true)
      (lib.cmakeFeature "SLIC3R_GTK" "3")
      (lib.cmakeBool "BUILD_TESTS" false)
      # breakpad: краш-дампы Creality — не нужны, библиотеки в nixpkgs нет
      # (использование в коде полностью под #ifdef USE_BREAKPAD)
      (lib.cmakeBool "ENABLE_BREAKPAD" false)
      (lib.cmakeBool "ORCA_TOOLS" false)
      (lib.cmakeBool "GENERATE_ORCA_HEADER" false)
      (lib.cmakeBool "SLIC3R_PERL_XS" false)
      (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DGL_SILENCE_DEPRECATION")
      (lib.cmakeFeature "CMAKE_EXE_LINKER_FLAGS" "-Wl,--no-as-needed")
      (lib.cmakeFeature "LIBNOISE_INCLUDE_DIR" "${super.libnoise}/include")
      (lib.cmakeFeature "LIBNOISE_LIBRARY_RELEASE" "${super.libnoise}/lib/libnoise-static.a")
      # Paho MQTT: указываем где лежат конфиги eclipse-paho-mqtt-c
      (lib.cmakeFeature "eclipse-paho-mqtt-c_DIR" "${super.paho-mqtt-c}/lib/cmake/eclipse-paho-mqtt-c")
      # Закрытые Creality-библиотеки: в репозитории есть готовые linux/x86_64
      # архивы (deps/CR_*). Задаём пути кешем — find_library() тогда ничего не
      # ищет, а CR_KM_RECIPE сам выводит include-каталог из пути к .a.
      "-DCP_TPMS_Gradual:FILEPATH=${finalAttrs.src}/deps/CR_TPMS/cr_tpms/lib/linux/x86_64/libcr_tpms_library.a"
      "-DCP_KM_Recipe:FILEPATH=${finalAttrs.src}/deps/CR_KM_RECIPE/cr_km_recipe/lib/linux/x86_64/libcr_km_recipe.a"
      "-DCP_FILLTENSOR_Gradual:FILEPATH=${finalAttrs.src}/deps/CR_CLOSED/CR_FILLTENSOR/cr_FillTensor/lib/linux/x86_64/libcr_FillTensor_library.a"
      "-Wno-dev"
    ];

    env = {
      # Не ставим NLOPT — cmake/modules/FindNLopt.cmake при незаданной
      # переменной ищет nlopt (без суффикса _cxx) через find_library.
      # NLOPT = super.nlopt;

      NIX_CFLAGS_COMPILE = toString [
        "-Wno-ignored-attributes"
        "-I${super.opencv.out}/include/opencv4"
        "-I${super.libnoise}/include"
        # MetaRTC: заголовки лежат в include/metartc/, а исходники включают их
        # как "yangplayer/...", "yangutil/..." — нужен именно этот каталог.
        "-I${metartc}/include/metartc"
        # Закрытые Creality-библиотеки: реальные заголовки из deps/ (TPMS,
        # K-M recipe/цветоделение, FillTensor).
        "-I${finalAttrs.src}/deps/CR_TPMS/cr_tpms/include"
        "-I${finalAttrs.src}/deps/CR_KM_RECIPE/cr_km_recipe/include"
        "-I${finalAttrs.src}/deps/CR_CLOSED/CR_FILLTENSOR/cr_FillTensor/include"
        # gcc-14 сделал incompatible-pointer-types ошибкой; в GUI-коде
        # (boost/cairo) встречаются несовпадения указателей — глобально в warn.
        "-Wno-error=incompatible-pointer-types"
        "-Wno-error=format-security"
        "-Wno-uninitialized"
        "-Wno-unused-result"
        "-Wno-deprecated-declarations"
        "-Wno-format-overflow"
        # libboost_log.so экспортирует неймспейс v2_mt_posix (с BOOST_LOG_DLL),
        # а без этого флага часть таргетов (libslic3r_cgal — нет boost_headeronly
        # в link libs) компилируется в статическом неймспейсе v2s_mt_posix →
        # undefined refs при линковке. Глобально задаём dyn-link.
        "-DBOOST_ALL_DYN_LINK"
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
        # CrealityPrint.cpp вызывает XInitThreads, но таргет не линкует X11 явно
        "-lX11"
        # WebView.cpp использует webkit API напрямую
        "-lwebkit2gtk-4.1"
      ];
    };

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
      # src/CMakeLists.txt жёстко ставит RUNTIME DESTINATION "./" (ветка
      # не-WIN32), поэтому бинарник оказывается в $out/CrealityPrint. Переносим
      # в стандартный $out/bin (SLIC3R_FHS кладёт ресурсы в $out/share по
      # абсолютному пути, так что положение бинарника не критично).
      if [ -e "$out/CrealityPrint" ]; then
        mkdir -p "$out/bin"
        mv "$out/CrealityPrint" "$out/bin/CrealityPrint"
      fi
    '';

    separateDebugInfo = true;

    meta = {
      description = "G-code generator for 3D printers (Creality), git master build";
      homepage = "https://github.com/CrealityOfficial/CrealityPrint";
      changelog = "https://github.com/CrealityOfficial/CrealityPrint/commits/master/";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ ];
      mainProgram = "CrealityPrint";
      platforms = lib.platforms.linux;
    };
  });
}
