{self, inputs, ...}: {
    flake.nixosModules.laptopConf = {pkgs, lib, ...}: {
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

        networking.hostName = "nixos";
        networking.networkmanager.enable = true;
    };
}
