{ pkgs, hostname, ... }:
{
  imports = [
    ../common.nix
    ./hardware.nix
  ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  users.users.dvt.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = with pkgs; [
    btop-rocm
  ];

  system.stateVersion = "25.11";
}
