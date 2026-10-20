{ inputs }:
self: super:
let
  inherit (super) lib;

  # Тот же wx, что и у orca-slicer-git: propgrid (нужен wxInspector),
  # webkit/EGL/private fonts + libsecret + без debug-диалогов.
  # Выражение идентично orca-slicer-git.nix, поэтому обе сборки
  # дают одну и ту же замену wx (кэш nix общий).
  # Версия прибита к 3.3.3.1: в 3.3.4 у wxGridCellChoiceEditor убран
  # OnComboCloseUp (используется в GUI_ObjectTable.cpp), сборка падает.
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
          "--enable-debug=no"
          "--enable-secretstore"
        ];
      });
in
{
  # Инспектор wx-виджетов: OrcaSlicer подключает его как библиотеку
  # (find_package(wxInspector) + wxInspector::wxInspector) для Design/CAD-таба.
  wxinspector = super.clangStdenv.mkDerivation (finalAttrs: {
    pname = "wxinspector";
    version = "1.0.0";

    src = super.fetchFromGitHub {
      owner = "Noisyfox";
      repo = "wxInspector";
      tag = "v${finalAttrs.version}";
      hash = "sha256-AQbV2vAGJXatAXwLAxhWVXTdKqxj2v0THexQyKbroJw=";
    };

    nativeBuildInputs = [
      super.cmake
      super.pkg-config
      # FindwxWidgets ищет wx-config в PATH.
      wxGTK'
    ];

    buildInputs = [
      wxGTK'
      # CMakeLists wxInspector дополнительно шарит pkg-config gtk+-3.0,
      # если wx собран под GTK3.
      super.gtk3
    ];

    cmakeFlags = [
      # wx у Orca собирается релизным (--enable-debug=no), где wxDEBUG_LEVEL=0;
      # уровень должен совпадать при компиляции потребителя.
      (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DwxDEBUG_LEVEL=0")
      # Библиотека линкуется в общий код libslic3r_gui.
      (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    ];

    meta = {
      description = "Widget and layout inspection tool for wxWidgets applications";
      homepage = "https://github.com/Noisyfox/wxInspector";
      license = with lib.licenses; [
        lgpl2Plus
        wxWindowsException31
      ];
      platforms = lib.platforms.linux;
    };
  });
}
