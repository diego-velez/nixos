{
  pkgs,
  lib,
  osConfig,
  hostname,
  ...
}:

let
  fuzzelFontSize = if hostname == "desktop" then "32" else "20";
  powerMenuScript = pkgs.writeShellApplication {
    name = "power-menu";
    text = builtins.replaceStrings [ "@fontSize@" ] [ fuzzelFontSize ] (
      builtins.readFile ./scripts/power-menu
    );
  };
  toggleWaybarScript = pkgs.writeShellApplication {
    name = "toggle-waybar";
    runtimeInputs = [ pkgs.waybar pkgs.procps pkgs.psmisc ];
    text = builtins.replaceStrings [ "@waybar@" ] [ "${lib.getExe pkgs.waybar}" ] (
      builtins.readFile ./scripts/toggle-waybar
    );
  };
in
{
  imports = [
    ./configs/git.nix
    ./configs/lazygit.nix
    ./configs/starship.nix
    ( import ./configs/kanata.nix {
      inherit lib pkgs hostname;
    } )
  ];

  home.username = "dvt";
  home.homeDirectory = "/home/dvt";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = osConfig.system.stateVersion;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    powerMenuScript
    toggleWaybarScript
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "waybar/style.css".source = ./configs/waybar/style.css;
    "waybar/toggle_wireguard_vpn".source = ./configs/waybar/toggle_wireguard_vpn;
    "waybar/config".text = import ./configs/waybar/config.nix {
      inherit hostname;
    };

    "niri/config.kdl".text = import ./configs/niri.nix {
      inherit lib hostname powerMenuScript toggleWaybarScript;
    };

    "quickshell".source = ./configs/quickshell;
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
  };
}
