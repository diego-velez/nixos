{
  pkgs,
  pkgsUnstable,
  lib,
  machine,
  osConfig,
  ...
}:

let
  fuzzelFontSize = if machine == "desktop" then "32" else "20";
  powerMenuScript = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [
      fuzzel
      procps
      dracula-theme
      dracula-icon-theme
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
    ./git.nix
    ./lazygit.nix
    ./starship.nix
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

    # Programming
    tree-sitter
    gcc
    gnumake
  ];

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
  };
}
