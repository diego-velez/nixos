{
  pkgs,
  pkgsUnstable,
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
    text = builtins.readFile ./scripts/set-wallpaper.sh;
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

    kanata
    wl-gammarelay-rs

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

  # programs.mise = {
  #   enable = true;
  #   enableFishIntegration = true;
  #   package = pkgsUnstable.mise;
  # };

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
      ;
  };

  xdg.configFile."quickshell".source = ./quickshell;

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
    RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/ripgrep.conf";
    TERMINAL = "wezterm";
    JAVA_HOME = "${pkgs.jdk}";
  };
}
