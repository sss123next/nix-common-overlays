{ inputs }:
self: super: {
  flacon_my =
    with super;
    flacon.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchGit {
        url = "https://github.com/flacon/flacon";
        ref = "master";
      };
      nativeBuildInputs = [ 
    cmake 
    pkg-config 
    qt6.wrapQtAppsHook 
  ]; 
  buildInputs = [ 
    qt6.qtbase 
    qt6.qttools 
    libuchardet 
    taglib 
  ];
    });
}
