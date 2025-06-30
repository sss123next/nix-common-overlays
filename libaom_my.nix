{ inputs }:
self: super: {
  libaom_my = with super; libaom;
#   libaom_my =
#     with super;
#     (libaom.override {
#       #stdenv = llvmPackages_15.stdenv;
#       #enableButteraugli = true;
#       enableVmaf = true;
#     }).overrideAttrs
#       (old: rec {
# #         version = "git";
# #         src = fetchGit {
# #           url = "https://aomedia.googlesource.com/aom";
# #           ref = "main";
# #                                 rev = "46eb4e460154505f205f7d53c8054268b58aba7a";
# # #          rev = "e0e69ad3aa30b38135337c1a7dfd7f1535d335c8";
# #         };
#         #configureFlags =(lib.lists.remove "--enable-avresample" (lib.lists.remove "--disable-avresample" oldAttrs.configureFlags))
# #        patches = [ /home/sss/nix/patches/libaom/libaom.patch ];
# #        patches = [];
#       });
}
