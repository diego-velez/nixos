{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  machine,
  osConfig,
  inputs,
  ...
}:

let
  fuzzelFontSize = if machine == "desktop" then "32" else "20";
  powerMenuScript = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [
      fuzzel
      dracula-theme
      dracula-icon-theme
      systemd
    ];
    text = builtins.replaceStrings [ "@fontSize@" ] [ fuzzelFontSize ] (
      builtins.readFile ./scripts/power-menu.sh
    );
  };
  toggleWaybarScript = pkgs.writeShellApplication {
    name = "toggle-waybar";
    runtimeInputs = with pkgs; [
      waybar
      procps
      psmisc
    ];
    text = builtins.replaceStrings [ "@waybar@" ] [ "${lib.getExe pkgs.waybar}" ] (
      builtins.readFile ./scripts/toggle-waybar.sh
    );
  };
  setWallpaper = pkgs.writeShellApplication {
    name = "set-wallpaper";
    runtimeInputs = [
      pkgsUnstable.awww
    ];
    text = builtins.replaceStrings [ "@wallpaperFolder@" ] [ "${../../wallpapers}" ] (
      builtins.readFile ./scripts/set-wallpaper.sh
    );
  };
  eyeBreak = pkgs.writeShellApplication {
    name = "eye-break";
    runtimeInputs = with pkgs; [
      libnotify
    ];
    text = builtins.readFile ./scripts/eye-break.sh;
  };
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
    ./theme.nix
    ./fish.nix
    ./zen.nix
    ./git.nix
    ./lazygit.nix
    ./starship.nix
    ./imv.nix
    ./kanata.nix
  ];

  home.username = "dvt";
  home.homeDirectory = "/home/dvt";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = osConfig.system.stateVersion;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    powerMenuScript
    toggleWaybarScript
    setWallpaper
    eyeBreak

    kanata
    wl-gammarelay-rs
    jupyter
    pkgsUnstable.antigravity-fhs

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
  ];

  # We want this for automatic sourcing of dev shell when cd'ing into project with .envrc
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.swaylock = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font";
      font-size = 32;
      indicator-radius = 100;
      inside-color = "282A36";
      inside-clear-color = "F1FA8C";
      inside-ver-color = "50FA7B";
      inside-wrong-color = "FF5555";
      key-hl-color = "F1FA8C";
      ring-color = "383A46";
      ring-clear-color = "F1FA8C";
      ring-ver-color = "50FA7B";
      ring-wrong-color = "FF5555";
      separator-color = "282A36";
      text-color = "F8F8F2";
      text-ver-color = "F8F8F2";
      text-wrong-color = "F8F8F2";
      image = "~/.config/swaylock/wallpaper";
    };
  };

  services.swayidle =
    let
      # Either 'off' or 'on'
      display = status: "${lib.getExe pkgs.niri} msg action power-${status}-monitors";
      updateGammaBy =
        gamma:
        "${pkgs.systemd}/bin/busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateGamma d ${gamma}";
      setGamma =
        gamma:
        "${pkgs.systemd}/bin/busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Gamma d ${gamma}";
      lock = "${lib.getExe pkgs.swaylock} --daemonize";
    in
    {
      enable = true;
      timeouts = [
        # Dim screen
        {
          timeout = 300; # 5 minutes
          command = updateGammaBy "0.5";
          resumeCommand = setGamma "1";
        }
        # Lock screen
        {
          timeout = 900; # 15 minutes
          command = lock;
        }
        # Turn off screen
        {
          timeout = 1500; # 25 minutes
          command = display "off";
          resumeCommand = display "on";
        }
        # Go to sleep
        {
          timeout = 1800; # 30 minutes
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        before-sleep = (display "off") + "; " + lock;
        after-resume = display "on";
        lock = (display "off") + "; " + lock;
        unlock = display "on";
      };
    };

  # This is needed for swayidle dim screen timeout
  systemd.user.services.wl-gammarelay = {
    Unit = {
      Description = "Software-based screen dimming daemon";
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe pkgs.wl-gammarelay-rs} run";
      Restart = "always";
      RestartSec = 5;
    };
  };

  services.cliphist.enable = true;
  services.awww = {
    enable = true;
    package = pkgsUnstable.awww;
  };

  services.mpris-proxy.enable = true;

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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      github = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github";
        identitiesOnly = true;
      };
    };
  };

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

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=18";
        prompt = ''"󱞫 "'';
        icons-enabled = true;
        icon-theme = "Dracula";
        sort-result = true;
        match-counter = true;
      };
      border = {
        width = 2;
        radius = 100;
      };
      colors = {
        background = "282A36FF";
        text = "F8F8F2FF";
        prompt = "6272A4FF";
        placeholder = "6272A4FF";
        input = "F8F8F2FF";
        match = "50FA7BFF";
        selection = "44475AFF";
        selection-text = "F8F8F2FF";
        selection-match = "50FA7BFF";
        counter = "6272A4FF";
        border = "F8F8F2FF";
      };
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--smart-case"
    ];
  };

  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font Mono 14";
      background-color = "#282A36";
      text-color = "#F8F8F2";
      border-color = "#FFB86C";
      border-radius = "10";
      icons = "1";
      width = "500";
      text-alignment = "center";
      anchor = "top-center";
      max-history = "100";
      default-timeout = "5000";
    };
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

  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."waybar/toggle_wireguard_vpn".source = ./waybar/toggle_wireguard_vpn;
  xdg.configFile."waybar/config".text = import ./waybar/config.nix {
    inherit machine;
  };

  xdg.configFile."niri/config.kdl".text = import ./niri.nix {
    inherit
      lib
      machine
      powerMenuScript
      toggleWaybarScript
      setWallpaper
      eyeBreak
      ;
  };

  xdg.configFile."quickshell".source = ./quickshell;
  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink ./wezterm;
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink ../../nvim;

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
    EDITOR = "nvim";
    FZF_DEFAULT_OPTS = "--layout=reverse";
    TERMINAL = "wezterm";
    JAVA_HOME = "${pkgs.jdk}";
    MANGOHUD = "1";
  };
}
