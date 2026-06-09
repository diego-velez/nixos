{
  lib,
  pkgs,
  ...
}:
{
  programs.fish = {
    enable = true;

    binds = {
      "ctrl+d" = {
        name = "\\cd";
        command = "";
        mode = "insert";
        silent = true;
      };
    };

    interactiveShellInit = ''
      # Disable welcome message
      set fish_greeting

      # Use the vi key binds
      set -g fish_key_bindings fish_hybrid_key_bindings
      set fish_vi_force_cursor 1
      set fish_cursor_default block
      set fish_cursor_insert line

      ${builtins.readFile ./fish/fish_title.fish}

      # TODO: Just use HM after https://github.com/nix-community/home-manager/pull/9379 is merged
      ${lib.getExe pkgs.devenv} hook fish | source
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

  xdg.configFile."fish/conf.d/fish_frozen_theme.fish".text = ''
    # This file was created by fish when upgrading to version 4.3, to migrate
    # theme variables from universal to global scope.
    # Don't edit this file, as it will be written by the web-config tool (`fish_config`).
    # To customize your theme, delete this file and see
    #     help interactive#syntax-highlighting
    # or
    #     man fish-interactive | less +/^SYNTAX.HIGHLIGHTING
    # for appropriate commands to add to ~/.config/fish/config.fish instead.
    # See also the release notes for fish 4.3.0 (run `help relnotes`).

    set --global fish_color_autosuggestion 6272a4
    set --global fish_color_cancel ff5555 --reverse
    set --global fish_color_command 8be9fd
    set --global fish_color_comment 6272a4
    set --global fish_color_cwd 50fa7b
    set --global fish_color_cwd_root red
    set --global fish_color_end ffb86c
    set --global fish_color_error ff5555
    set --global fish_color_escape ff79c6
    set --global fish_color_history_current --bold
    set --global fish_color_host bd93f9
    set --global fish_color_host_remote bd93f9
    set --global fish_color_keyword ff79c6
    set --global fish_color_normal f8f8f2
    set --global fish_color_operator 50fa7b
    set --global fish_color_option ffb86c
    set --global fish_color_param bd93f9
    set --global fish_color_quote f1fa8c
    set --global fish_color_redirection f8f8f2
    set --global fish_color_search_match --bold --background=44475a
    set --global fish_color_selection --bold --background=44475a
    set --global fish_color_status ff5555
    set --global fish_color_user 8be9fd
    set --global fish_color_valid_path --underline=single
    set --global fish_pager_color_background
    set --global fish_pager_color_completion f8f8f2
    set --global fish_pager_color_description 6272a4
    set --global fish_pager_color_prefix 8be9fd
    set --global fish_pager_color_progress 6272a4
    set --global fish_pager_color_secondary_background
    set --global fish_pager_color_secondary_completion
    set --global fish_pager_color_secondary_description
    set --global fish_pager_color_secondary_prefix
    set --global fish_pager_color_selected_background --background=44475a
    set --global fish_pager_color_selected_completion f8f8f2
    set --global fish_pager_color_selected_description 6272a4
    set --global fish_pager_color_selected_prefix 8be9fd
  '';
}
