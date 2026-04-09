{self, ...}: {
    flake.nixosModules.laptopConf = {pkgs, ...}: {
        imports = [
            # ../common.nix
            self.nixosModules.common
            self.nixosModules.laptopHardware
        ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
        };

        networking.hostName = "DVT_on_ROG";
        networking.networkmanager.enable = true;

        powerManagement.enable = true;
        services.auto-cpufreq = {
            enable = true;
            settings = {
              battery = {
                 governor = "powersave";
                 turbo = "never";
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
        ];
    };
}
