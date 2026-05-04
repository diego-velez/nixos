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
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
    ./git.nix
    ./lazygit.nix
    ./starship.nix
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

    kanata
    wl-gammarelay-rs

    # Programming
    tree-sitter
    gcc
    gnumake
  ];

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name = "graphite-light";
    package = pkgs.graphite-cursors;
    size = 26;
  };

  programs.imv = {
    enable = true;
    settings = {
      options = {
        background = "282A36";
      };

      binds = {
        q = "quit";
        c = "center";
        r = "reset";
        y = ''exec wl-copy "$imv_current_file"'';

        # Panning
        "<Left>" = "pan 50 0";
        "<Right>" = "pan -50 0";
        "<Up>" = "pan 0 50";
        "<Down>" = "pan 0 -50";

        # Image navigation
        n = "next";
        p = "prev";
        gg = "goto 1";
        "<Shift+G>" = "goto -1";

        # Zooming
        i = "zoom 1";
        o = "zoom -1";
        a = "zoom actual";
      };
    };
  };

  programs.zen-browser = {
    enable = true;
    languagePacks = [ "en-US" ];
    setAsDefaultBrowser = true;
    enablePrivateDesktopEntry = true;

    policies =
      let
        mkLockedAttrs = builtins.mapAttrs (
          _: value: {
            Value = value;
            Status = "locked";
          }
        );

        mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

        mkExtensionEntry =
          {
            id,
            pinned ? false,
          }:
          let
            base = {
              install_url = mkPluginUrl id;
              installation_mode = "force_installed";
            };
          in
          if pinned then base // { default_area = "navbar"; } else base;

        mkExtensionSettings = builtins.mapAttrs (
          _: entry: if builtins.isAttrs entry then entry else mkExtensionEntry { id = entry; }
        );
      in
      {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true; # save webs for later reading
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        SanitizeOnShutdown = {
          FormData = true;
          Cache = true;
        };
        ExtensionSettings = mkExtensionSettings {
          "uBlock0@raymondhill.net" = mkExtensionEntry {
            id = "ublock-origin";
            pinned = true;
          };
          "keepassxc-browser@keepassxc.org" = mkExtensionEntry {
            id = "keepassxc-browser";
            pinned = true;
          };
          "addon@darkreader.org" = mkExtensionEntry {
            id = "darkreader";
            pinned = true;
          };
          "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "refined-github-";
          "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
          "github-no-more@ihatereality.space" = "github-no-more";
          "github-repository-size@pranavmangal" = "gh-repo-size";
          "firefox-extension@steamdb.info" = "steam-database";
          "@searchengineadremover" = "searchengineadremover";
          "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";
          "trackmenot@mrl.nyu.edu" = "trackmenot";
          "{861a3982-bb3b-49c6-bc17-4f50de104da1}" = "custom-user-agent-revived";
        };
        Preferences = mkLockedAttrs {
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.warnOnClose" = false;
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
          # Disable swipe gestures (Browser:BackOrBackDuplicate, Browser:ForwardOrForwardDuplicate)
          "browser.gesture.swipe.left" = "";
          "browser.gesture.swipe.right" = "";
          "browser.tabs.hoverPreview.enabled" = true;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.topsites.contile.enabled" = false;

          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
          "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
          "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
          "privacy.resistFingerprinting.block_mozAddonManager" = true;
          "privacy.spoof_english" = 1;

          "privacy.firstparty.isolate" = true;
          "network.cookie.cookieBehavior" = 5;
          "dom.battery.enabled" = false;

          "gfx.webrender.all" = true;
          "network.http.http3.enabled" = true;
          "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0
        };
      };

    profiles.default = {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "full-screen-api.ignore-widgets" = true;
        "zen.welcome-screen.seen" = true;
      };

      mods = [
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
        "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
        "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
      ];

      keyboardShortcutsVersion = 17;
      keyboardShortcuts = [
        {
          id = "zen-compact-mode-toggle";
          key = "c";
          modifiers.alt = true;
        }
        {
          id = "zen-toggle-sidebar";
          key = "s";
          modifiers.alt = true;
        }
        {
          id = "zen-close-all-unpinned-tabs";
          disabled = true;
        }
        {
          id = "zen-workspace-backward";
          key = "[";
          modifiers.alt = true;
        }
        {
          id = "zen-workspace-forward";
          key = "]";
          modifiers.alt = true;
        }
        {
          id = "zen-new-empty-split-view";
          disabled = true;
        }
        {
          id = "zen-split-view-unsplit";
          key = "q";
          modifiers.alt = true;
        }
        {
          id = "zen-split-view-horizontal";
          key = "h";
          modifiers.alt = true;
        }
        {
          id = "zen-split-view-vertical";
          key = "v";
          modifiers.alt = true;
        }
        {
          id = "zen-split-view-grid";
          disabled = true;
        }
        {
          id = "zen-new-unsynced-window";
          disabled = true;
        }
        {
          id = "zen-glance-expand";
          disabled = true;
        }
        {
          id = "zen-toggle-pin-tab";
          disabled = true;
        }
        {
          id = "zen-copy-url-markdown";
          disabled = true;
        }
        {
          id = "key_closeWindow";
          disabled = true;
        }
        {
          id = "key_quitApplication";
          disabled = true;
        }
        {
          id = "goBackKb2";
          disabled = true;
        }
        {
          id = "goForwardkKb2";
          disabled = true;
        }
        {
          id = "goHome";
          disabled = true;
        }
        {
          id = "key_search";
          disabled = true;
        }
        {
          id = "key_search2";
          disabled = true;
        }
        {
          id = "key_findAgain";
          disabled = true;
        }
        {
          id = "key_findPrevious";
          disabled = true;
        }
        {
          id = "focusURLBar2";
          disabled = true;
        }
        {
          id = "key_savePage";
          disabled = true;
        }
        {
          id = "key_togglePictureInPicture";
          disabled = true;
        }
        {
          id = "key_viewSource";
          disabled = true;
        }
        {
          id = "key_viewInfo";
          disabled = true;
        }
        {
          id = "key_switchTextDirection";
          disabled = true;
        }
      ];

      search = {
        force = true;
        default = "brave";
        engines = {
          brave = {
            name = "Brave Search";
            urls = [
              {
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "brave" ];
          };
        };
      };
    };
  };

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
      # TODO: set wallpaper eventually
      # image = ~/.config/swaylock/wallpaper;
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
      ;
  };

  xdg.configFile."quickshell".source = ./quickshell;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };
  };

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
  };
}
