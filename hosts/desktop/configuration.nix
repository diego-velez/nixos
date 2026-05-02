{pkgs, hostname, ...}: {
    imports = [
        ../common.nix
        ./hardware.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
    };

    networking.hostName = hostname;
    networking.networkmanager.enable = true;

    users.users.dvt.extraGroups = ["video" "render"];

    environment.systemPackages = with pkgs; [
        btop
    ];

    system.stateVersion = "25.11";
}
