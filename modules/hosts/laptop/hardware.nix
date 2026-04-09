{self, inputs, ...}: {
     flake.nixosModules.laptopHardware = {config, lib, pkgs, modulesPath, ...}: {
        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
        boot.initrd.kernelModules = [];
        boot.kernelModules = ["kvm-amd"];
        boot.extraModulePackages = [];

        fileSystems."/" = {
            device = "/dev/disk/by-uuid/9c290aea-61d6-4757-89ec-ad0ed80f3122";
            fsType = "ext4";
        };

        fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/0C85-4602";
            fsType = "vfat";
            options = [
                "fmask=0077"
                "dmask=0077"
            ];
        };

        swapDevices = [];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        hardware.uinput.enable = true;
     };
}
