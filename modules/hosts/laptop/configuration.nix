{self, ...}: {
    flake.nixosModules.laptopConf = {...}: {
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
    };
}
