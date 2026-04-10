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

    powerManagement.enable = true;
    services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
             governor = "powersave";
             turbo = "never";
             enable_thresholds = true;
             start_threshold = 70;
             stop_threshold = 80;
          };
          charger = {
             governor = "performance";
             turbo = "auto";
          };
        };
    };

    users.users.dvt.extraGroups = ["video" "render" "nvidia"];

    environment.systemPackages = with pkgs; [
        (btop.override {cudaSupport = true;})
        nvtopPackages.full
        powertop
        brightnessctl
        kanata
    ];

    system.stateVersion = "25.11";
}
