{ inputs }:
self: super: {
  orca-slicer_my =
    with super;
    (orca-slicer.override {
    }).overrideAttrs
      (old: rec {
        version = "git";
        src = fetchGit {
          url = "https://github.com/SoftFever/OrcaSlicer";
          ref = "main";
        };
        doCheck = false;
        patches = [ ];
      });
}
