{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Disable welcome message
      set fish_greeting

      # Use the vi key binds
      set -g fish_key_bindings fish_hybrid_key_bindings
      set fish_vi_force_cursor 1
      set fish_cursor_default block
      set fish_cursor_insert line

      ${builtins.readFile ./fish/fish_title.fish}
    '';

    shellAliases = {
      # Prefered optons for common programs
      df = "df --total -h -T";
      free = "free -h";
      nano = "nano -E -S -i -l -q";
      more = "less";
      open = "xdg-open";
      fd = "fd --hidden --no-ignore";
      # Change ls for exa
      ls = "eza --color=always --group-directories-first -a --icons";
      ll = "eza --color=always --group-directories-first -a -l -h -G --icons";
      lt = "eza --color=always --group-directories-first -a -T --icons";
      # Change cat for bat
      cat = "bat --theme Dracula";
      # Colorized grep
      grep = "grep --colour=always";
      egrep = "egrep --colour=always";
      fgrep = "fgrep --colour=always";
      # Confirm before overwriting something
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -I";
    };

    shellAbbrs = {
      config = "git --git-dir=$HOME/.files/ --work-tree=$HOME";
      rumad = "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa estudiante@rumad.uprm.edu";
    };

    functions = {
      git_uni = {
        description = "Setup Git repo for university work";
        body = builtins.readFile ./fish/git_uni.fish;
      };
    };
  };
}
