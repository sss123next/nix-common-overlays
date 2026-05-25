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
    libsForQt6.wrapQtAppsHook 
  ]; 
  buildInputs = [ 
    libsForQt6.qtbase 
    libsForQt6.qttools 
    libuchardet 
    taglib 
  ];
    });
}
