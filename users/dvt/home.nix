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

  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."waybar/toggle_wireguard_vpn".source = ./waybar/toggle_wireguard_vpn;
  xdg.configFile."waybar/config".text = import ./waybar/config.nix {
    inherit machine;
  };

  # xdg.configFile."niri/config.kdl".text = import ./niri.nix {
  #   inherit
  #     lib
  #     machine
  #     powerMenuScript
  #     toggleWaybarScript
  #     setWallpaper
  #     ;
  # };

  programs.niri.settings = {
    cursor.hide-when-typing = true;
    input.warp-mouse-to-focus.enable = true;
    gestures.hot-corners.enable = false;
    layout = {
      gaps = 5;
      struts = {
        left = 5;
        right = 5;
        top = 5;
        bottom = 5;
      };
      center-focused-column = "on-overflow";
      always-center-single-column = true;
      empty-workspace-above-first = true;
      preset-column-widths = [
        { proportion = 0.2; }
        { proportion = 0.3; }
        { proportion = 0.4; }
        { proportion = 0.5; }
        { fixed = 3440; } # 21:9
      ];
      default-column-display = "tabbed";
      default-column-width.proportion = 0.5;
      focus-ring.enable = false;
      border = {
        enable = true;
        width = 2;
        active = {
          color = "#BD93F9";
        };
        inactive = {
          color = "#44475AAA";
        };
      };
      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset.x = 0;
        offset.y = 5;
        color = "#1E202966";
      };
      insert-hint = {
        enable = true;
        display = {
          color = "#A4FFFF80";
        };
      };
      tab-indicator = {
        enable = true;
        hide-when-single-tab = true;
        gap = 3;
        position = "top";
      };
    };
    hotkey-overlay.skip-at-startup = true;
    prefer-no-csd = true;
    screenshot-path = "~/Pictures/Screenshot from %Y-%m-%d %H-%M-%S.png";
    animations = {
      enable = true;
      workspace-switch = {
        enable = true;
        kind = {
          spring = {
            damping-ratio = 1.0;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };
      };
    };

    overview.backdrop-color = "#282A36";
    clipboard.disable-primary = true;
    # TODO: Recent windows settings

    window-rules = [
      # Open windows as floating by default
      {
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
          {
            app-id = "zen$";
            title = "^Picture-in-Picture$";
          }
          {
            app-id = "zen$";
            title = "^Library$";
          }
          {
            app-id = "zen$";
            title = "About Zen Browser$";
          }
          { app-id = "thunar$"; }
          { app-id = "qalculate-gtk$"; }
          { app-id = "org.gnome.FileRoller$"; }
          { app-id = "org.gnome.Nautilus$"; }
          { app-id = "file-roller$"; }
          { app-id = "Sign in.*$/gmi"; }
          { app-id = "xdg-desktop-portal-gtk$"; }
          { app-id = "nemo$"; }
          { app-id = "eom$"; }
          { app-id = "Library$"; }
          { app-id = "Acceso: Cuentas de Google$"; }
          { app-id = "Android Emulator.*$/i"; }
          { app-id = "file-jpeg$"; }
          { app-id = "file-png$"; }
          { app-id = "org.qbittorrent.qBittorrent"; }
          { app-id = "steam"; }
        ];
        excludes = [
          {
            app-id = "org.qbittorrent.qBittorrent";
            title = "qBittorrent";
          }
          {
            app-id = "steam";
            title = "Steam";
          }
        ];
        open-floating = true;
      }

      # Machine-specific column widths
      {
        matches = [
          { app-id = "org.keepassxc.KeePassXC"; }
          { app-id = "org.gnome.Rhythmbox3"; }
          { app-id = "org.wezfurlong.wezterm"; }
        ];
        default-column-width.proportion = if machine == "desktop" then 0.3 else 0.5;
      }

      {
        matches = [
          { app-id = "org.pwmt.zathura"; }
          { app-id = "org.pulseaudio.pavucontrol"; }
          {
            app-id = "org.qbittorrent.qBittorrent";
            title = "qBittorrent";
          }
        ];
        default-column-width.proportion = 0.2;
      }

      {
        matches = [
          {
            app-id = "virt-manager";
            title = "Virtual Machine Manager";
          }
        ];
        default-column-width.fixed = 324;
      }

      {
        matches = [ { app-id = "org.gnome.Nautilus$"; } ];
        default-column-width.fixed = 1000;
        default-window-height.fixed = 900;
      }

      # Set rules for floating windows
      {
        matches = [ { is-floating = true; } ];
        min-width = 400;
        max-width = 2038;
        min-height = 400;
        max-height = 1380;
      }

      # Privacy: Block screen capture for password managers
      {
        matches = [
          { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
          { app-id = "^org\\.gnome\\.World\\.Secrets$"; }
        ];
        block-out-from = "screen-capture";
      }

      # Global window rules
      {
        draw-border-with-background = false;
        geometry-corner-radius = {
          bottom-left = 10.0;
          bottom-right = 10.0;
          top-left = 10.0;
          top-right = 10.0;
        };
        clip-to-geometry = true;
      }
    ];

    spawn-at-startup = [
      { sh = "waybar"; }
      {
        argv = [
          "quickshell"
          "--daemonize"
        ];
      }
      { sh = "wl-paste -t text --watch cliphist store"; }
      { sh = "wl-paste -t image --watch cliphist store"; }
    ];
    binds = {
      # Mod+Ctrl+Slash { show-hotkey-overlay; }
      "Mod+Ctrl+Slash".action.show-hotkey-overlay = [ ];

      # Suggested binds for running programs
      "Mod+T" = {
        repeat = false;
        hotkey-overlay.title = "Open a Terminal: Wezterm";
        action.spawn = "wezterm";
      };
      "Mod+R" = {
        repeat = false;
        hotkey-overlay.title = "Run an Application: Fuzzel";
        action.spawn = "fuzzel";
      };
      "Mod+E" = {
        repeat = false;
        hotkey-overlay.title = "Run an Application: Thunar";
        action.spawn = "thunar";
      };
      "Mod+B" = {
        repeat = false;
        hotkey-overlay.title = "Run an Application: Zen";
        action.spawn = "zen-beta";
      };
      "Mod+Q" = {
        repeat = false;
        hotkey-overlay.title = "Power menu";
        action.spawn = "${lib.getExe powerMenuScript}"; # Assuming these are defined in your scope
      };
      "Mod+H" = {
        repeat = false;
        hotkey-overlay.title = "Toggle Waybar";
        action.spawn = "${lib.getExe toggleWaybarScript}";
      };
      "Mod+L" = {
        repeat = false;
        hotkey-overlay.title = "Lock Session";
        action.spawn-sh = "loginctl lock-session";
      };
      "Mod+V" = {
        repeat = false;
        hotkey-overlay.title = "Select Clipboard History";
        action.spawn-sh = "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
      };
      "Mod+M" = {
        repeat = false;
        hotkey-overlay.title = "Select Menu";
        action.spawn-sh = "~/.config/menus/menus";
      };

      # Audio Keys
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-volume"
          "-l"
          "1.5"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SOURCE@"
          "toggle"
        ];
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "play-pause"
        ];
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "next"
        ];
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "previous"
        ];
      };

      # Brightness Keys
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "quickshell"
          "ipc"
          "call"
          "brightness"
          "change_display"
          "10%+"
        ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "quickshell"
          "ipc"
          "call"
          "brightness"
          "change_display"
          "10%-"
        ];
      };
      "XF86KbdBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "quickshell"
          "ipc"
          "call"
          "brightness"
          "change_kbd"
          "20%+"
        ];
      };
      "XF86KbdBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "quickshell"
          "ipc"
          "call"
          "brightness"
          "change_kbd"
          "20%-"
        ];
      };

      # Window & Workspace Management
      "Mod+O".action.toggle-overview = [ ];
      "Mod+W".action.close-window = [ ];

      "Mod+N".action.focus-column-right-or-first = [ ];
      "Mod+P".action.focus-column-left-or-last = [ ];
      "Mod+Ctrl+N".action.move-column-right = [ ];
      "Mod+Ctrl+P".action.move-column-left = [ ];
      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];

      "Mod+U".action.focus-workspace-up = [ ];
      "Mod+D".action.focus-workspace-down = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+D".action.move-column-to-workspace-down = [ ];

      # Workspace by Index
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;

      # Columns & Layout
      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
      "Mod+Alt+N".action.focus-window-down-or-top = [ ];
      "Mod+Alt+P".action.focus-window-up-or-bottom = [ ];

      "Mod+S".action.center-column = [ ];
      "Mod+Ctrl+S".action.center-visible-columns = [ ];

      "Mod+Comma".action.switch-preset-column-width-back = [ ];
      "Mod+Period".action.switch-preset-column-width = [ ];

      "Mod+F".action.toggle-window-floating = [ ];
      "Mod+Ctrl+F".action.fullscreen-window = [ ];
      "Mod+Alt+F".action.switch-focus-between-floating-and-tiling = [ ];

      # Screenshots
      "Print".action.screenshot = [ ];
      "Mod+Print".action.screenshot-window = [ ];
      "Mod+Ctrl+Print".action.screenshot-screen = [ ];
    };
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
