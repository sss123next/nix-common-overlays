{ inputs }:
self: super: {
  qpwgraph_my =
    with super;
    qpwgraph.overrideAttrs (old: rec {
      src = fetchGit {
        url = "https://gitlab.freedesktop.org/rncbc/qpwgraph";
        ref = "main";
      };
    });
}
