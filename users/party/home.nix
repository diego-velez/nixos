{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  machine,
  inputs,
  ...
}:

let
  tmuxSessionizer = pkgs.writeShellApplication {
    name = "sessionize";
    runtimeInputs = with pkgs; [
      fd
      fzf
      tmux
    ];
    text = builtins.readFile ./scripts/tmux-sessionizer.sh;
  };
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
    ./fish.nix
    ./starship.nix
    ./imv.nix
    ./kanata.nix
  ];

  home.username = "party";
  home.homeDirectory = "/home/party";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.11";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    tmuxSessionizer

    kanata
    heroic
  ];

  home.shell.enableShellIntegration = true;

  programs.neovim = {
    enable = true;
    package = pkgsUnstable.neovim-unwrapped;
    defaultEditor = true;
    sideloadInitLua = true;
    withRuby = false; # To silence warnings
    withPython3 = false; # To silence warnings
    extraPackages = with pkgs; [
      # Programming
      tree-sitter
      gcc
      gnumake
      # Neovim LSPs, formatters and linters
      lua-language-server
      stylua
      gopls
      golangci-lint
      tinymist
      asm-lsp
      nixd
      nixfmt
      basedpyright
      ruff
      jq
      google-java-format
      templ
      prettier
      pgformatter
      hclfmt
      biome
      actionlint
      libclang
      bash-language-server
      (callPackage ./kotlin-lsp.nix { })
      jdk
      typescript-language-server
    ];
  };

  programs.fzf.enable = true;

  services.mpris-proxy.enable = true;

  services.udiskie = {
    enable = true;
    tray = "never";
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      program_options = {
        # replace with your favorite file manager
        file_manager = "${pkgs.thunar}/bin/thunar";
      };
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      window-title-basename = true;

      # Dracula color theme
      notification-error-bg = "rgba(255,85,85,1)";
      notification-error-fg = "rgba(248,248,242,1)";
      notification-warning-bg = "rgba(255,184,108,1)";
      notification-warning-fg = "rgba(68,71,90,1)";
      notification-bg = "rgba(40,42,54,1)";
      notification-fg = "rgba(248,248,242,1)";
      completion-bg = "rgba(40,42,54,1)";
      completion-fg = "rgba(98,114,164,1)";
      completion-group-bg = "rgba(40,42,54,1)";
      completion-group-fg = "rgba(98,114,164,1)";
      completion-highlight-bg = "rgba(68,71,90,1)";
      completion-highlight-fg = "rgba(248,248,242,1)";
      index-bg = "rgba(40,42,54,1)";
      index-fg = "rgba(248,248,242,1)";
      index-active-bg = "rgba(68,71,90,1)";
      index-active-fg = "rgba(248,248,242,1)";
      inputbar-bg = "rgba(40,42,54,1)";
      inputbar-fg = "rgba(248,248,242,1)";
      statusbar-bg = "rgba(40,42,54,1)";
      statusbar-fg = "rgba(248,248,242,1)";
      highlight-color = "rgba(255,184,108,0.5)";
      highlight-active-color = "rgba(255,121,198,0.5)";
      default-bg = "rgba(40,42,54,1)";
      default-fg = "rgba(248,248,242,1)";
      render-loading = true;
      render-loading-fg = "rgba(40,42,54,1)";
      render-loading-bg = "rgba(248,248,242,1)";

      # Recolor mode settings
      # Default keymap is <C-r>
      recolor = true;
      recolor-keephue = true;
      recolor-lightcolor = "rgba(40,42,54,1)";
      recolor-darkcolor = "rgba(248,248,242,1)";
    };
    mappings = {
      u = "navigate previous";
      d = "navigate next";
      "[index] <Left>" = "navigate_index collapse";
      "[index] <Right>" = "navigate_index expand";
      # See https://unix.stackexchange.com/a/321932
      "<C-o> feedkeys" = ''":exec thunar $FILE<Return>"'';
    };
  };

  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    settings = {
      command = "${lib.getExe pkgs.tmux} new-session -A";
      font-family = "JetBrainsMono Nerd Font Mono";
      font-style = "Regular";
      font-size = 12;
      adjust-underline-position = 2;
      theme = "Dracula";
      background-opacity = 0.85;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;

      keybind = [
        "clear"

        # General
        "ctrl+shift+comma=reload_config"
        "ctrl+shift+a=select_all"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+i=inspector:toggle"
        "ctrl+shift+p=previous_tab"
        "ctrl+shift+n=next_tab"

        # Font
        "ctrl+0=reset_font_size"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+equal=increase_font_size:1"

        # Search and nav
        "ctrl+shift+f=start_search"
        "ctrl+shift+end=scroll_to_bottom"
        "ctrl+shift+home=scroll_to_top"
        "ctrl+shift+u=scroll_page_fractional:-0.5"
        "ctrl+shift+d=scroll_page_fractional:0.5"
        "ctrl+shift+m=write_screen_file:open"
      ];
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    clock24 = true;
    keyMode = "vi";
    baseIndex = 1;
    mouse = true;
    historyLimit = 10000;
    extraConfig = lib.concatLines [
      ''set -a terminal-features "tmux-256color:RGB"''
      "set -g extended-keys on"
      "set -g renumber-windows on"
      "set -g status-position top"
      "set -g status-justify absolute-centre"
      ''set -g status-style "bg=default"''
      ''set -g window-status-current-style "fg=colour255,bg=default,bold"''
      ''set -g window-status-separator ""''
      ''set -g window-status-format "#[fg=colour240]#[default] #I:#W#{?window_flags,#{window_flags},} #[fg=colour240]#[default]"''
      ''set -g window-status-current-format "#[fg=colour252]#[default] #I:#W#{?window_flags,#{window_flags},} #[fg=colour252]#[default]"''
      "set -g status-interval 5"
      ''set -g status-left "#S"''
      ''set -g status-right ""''
      # for debugging
      ''set -g remain-on-exit "off"''

      # Tabs
      ''bind-key -n M-t new-window -c "#{pane_current_path}"''
      "bind-key -n M-w kill-window"
      "bind-key -n M-1 select-window -t 1"
      "bind-key -n M-2 select-window -t 2"
      "bind-key -n M-3 select-window -t 3"
      "bind-key -n M-4 select-window -t 4"
      "bind-key -n M-5 select-window -t 5"
      "bind-key -n M-6 select-window -t 6"
      "bind-key -n M-7 select-window -t 7"
      "bind-key -n M-8 select-window -t 8"
      "bind-key -n M-9 select-window -t 9"

      ''bind r source-file "~/.config/tmux/tmux.conf"''
      "bind b set -g status"
      ''bind f run "tmux neww ${lib.getExe tmuxSessionizer}"''
      ''bind P run "${lib.getExe tmuxSessionizer} ~/projects"''
      ''bind G neww -n "git" -S lazygit''
      "bind E show-environment -g"
    ];
  };

  programs.ssh.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      update_ms = 500;
      proc_left = true;
      proc_filter_kernel = true;
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      italic-text = "always";
      style = "full";
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--smart-case"
    ];
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      dracula-vim
      vim-surround
      vim-commentary
      vim-unimpaired
      vim-flagship
      vim-sleuth
      vim-repeat
      vim-vinegar
      ctrlp-vim
    ];
    extraConfig = builtins.readFile ./vim/vimrc;
  };

  xdg.configFile."wezterm".source = ./wezterm;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dvt/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    FZF_DEFAULT_OPTS = "--layout=reverse";
    TERMINAL = "ghostty";
    JAVA_HOME = "${pkgs.jdk}";
    MANGOHUD = "1";
  };
}
