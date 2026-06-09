{
  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/github";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Diego Vélez";
        email = "diego.velez.dev@gmail.com";
      };
      gpg.format = "ssh";
      pull.rebase = true;
    };
  };
}
