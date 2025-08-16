{ inputs }:
(self: super: {
  intel-compute-runtime =
    with super;
    intel-compute-runtime.overrideAttrs (oldAttrs: rec {
      version = "25.22.33944.9";
      #      version = "25.18.33578.11";
      src = fetchFromGitHub {
        owner = "intel";
        repo = "compute-runtime";
        rev = version;
        hash = "sha256-99FV6U4Gx5cOsS9tcIR97u++7+Pt7W/hEdJyVnLWuEw=";
        #                        hash = "sha256-5AKQieCc6Aq+Yg/ELQlDXdsvuSZqNuM6ZZlsqc0zwrU=";
      };
    });
})
