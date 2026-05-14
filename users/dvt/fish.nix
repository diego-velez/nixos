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
      rumad = "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa estudiante@rumad.uprm.edu";
    };

    functions = {
      git_uni = {
        description = "Setup Git repo for university work";
        body = builtins.readFile ./fish/git_uni.fish;
      };
    };
  };

  xdg.configFile."fish/fish_variables".text = ''
    # This file contains fish universal variable definitions.
    # VERSION: 3.0
    SETUVAR __fish_initialized:3800
    SETUVAR fish_color_autosuggestion:6272a4
    SETUVAR fish_color_cancel:ff5555\x1e\x2d\x2dreverse
    SETUVAR fish_color_command:8be9fd
    SETUVAR fish_color_comment:6272a4
    SETUVAR fish_color_cwd:50fa7b
    SETUVAR fish_color_cwd_root:red
    SETUVAR fish_color_end:ffb86c
    SETUVAR fish_color_error:ff5555
    SETUVAR fish_color_escape:ff79c6
    SETUVAR fish_color_history_current:\x2d\x2dbold
    SETUVAR fish_color_host:bd93f9
    SETUVAR fish_color_host_remote:bd93f9
    SETUVAR fish_color_keyword:ff79c6
    SETUVAR fish_color_normal:f8f8f2
    SETUVAR fish_color_operator:50fa7b
    SETUVAR fish_color_option:ffb86c
    SETUVAR fish_color_param:bd93f9
    SETUVAR fish_color_quote:f1fa8c
    SETUVAR fish_color_redirection:f8f8f2
    SETUVAR fish_color_search_match:\x2d\x2dbold\x1e\x2d\x2dbackground\x3d44475a
    SETUVAR fish_color_selection:\x2d\x2dbold\x1e\x2d\x2dbackground\x3d44475a
    SETUVAR fish_color_status:ff5555
    SETUVAR fish_color_user:8be9fd
    SETUVAR fish_color_valid_path:\x2d\x2dunderline\x3dsingle
    SETUVAR fish_key_bindings:fish_default_key_bindings
    SETUVAR fish_pager_color_background:\x1d
    SETUVAR fish_pager_color_completion:f8f8f2
    SETUVAR fish_pager_color_description:6272a4
    SETUVAR fish_pager_color_prefix:8be9fd
    SETUVAR fish_pager_color_progress:6272a4
    SETUVAR fish_pager_color_secondary_background:\x1d
    SETUVAR fish_pager_color_secondary_completion:\x1d
    SETUVAR fish_pager_color_secondary_description:\x1d
    SETUVAR fish_pager_color_secondary_prefix:\x1d
    SETUVAR fish_pager_color_selected_background:\x2d\x2dbackground\x3d44475a
    SETUVAR fish_pager_color_selected_completion:f8f8f2
    SETUVAR fish_pager_color_selected_description:6272a4
    SETUVAR fish_pager_color_selected_prefix:8be9fd
  '';
}
