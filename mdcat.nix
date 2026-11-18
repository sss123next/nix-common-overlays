{ inputs }:
self: super: {
  mdcat = super.rustPlatform.buildRustPackage rec {
    pname = "mdcat";
    version = "2.20.1";

    src = super.fetchFromGitHub {
      owner = "BIRSAx2";
      repo = "mdcat";
      rev = "mdcat-${version}";
      hash = "sha256-u7zwcuV9L60rdhTHu6Hj0mmKnC0RHvwPKO6FBDE9sM8=";
    };

    cargoHash = "sha256-bJzr4CTSIqpSjZVzGdPWtMLa+l8ICygA05Bnj0VwpEk=";

    patches = [ ];

    checkFlags = [ "--skip=mdpick::renders_the_file_selected_in_fzf" ];
    # Тест mdpick::renders_the_file_selected_in_fzf требует less в sandbox

    nativeBuildInputs = with super; [ pkg-config asciidoctor installShellFiles ];

    buildInputs = with super; [ curl.dev openssl.dev ];

    postInstall = ''
      ln -sr $out/bin/{mdcat,mdless}
      ln -sr $out/bin/{mdcat,mdpick}
      for bin in mdcat mdless mdpick; do
        installShellCompletion --cmd $bin \
          --bash <($out/bin/$bin --completions bash) \
          --fish <($out/bin/$bin --completions fish) \
          --zsh <($out/bin/$bin --completions zsh) || true
      done
    '';

    meta = with super.lib; {
      description = "cat for markdown: Show markdown documents in terminals";
      homepage = "https://github.com/BIRSAx2/mdcat";
      license = licenses.mpl20;
      maintainers = [ ];
      mainProgram = "mdcat";
    };
  };
}
