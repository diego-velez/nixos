{ pkgs, hostname, ... }:
{
  imports = [
    ./specific-config.nix
    ./hardware.nix
  ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  users.users.dvt.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = with pkgs; [
    (btop.override { cudaSupport = true; })
    nvtopPackages.full
    keymapp
  ];

  system.stateVersion = "25.11";
}
