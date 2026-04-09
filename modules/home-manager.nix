{self, inputs, ...}: {
    flake.nixosModules.dvt = {pkgs, lib, hostname, ...}: {
        imports = [ inputs.home-manager.nixosModules.home-manager ];

        home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs hostname;};
            users.dvt = import ./_home/home.nix;
        };
    };
}
