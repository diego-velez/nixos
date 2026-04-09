# This shit is for flake-parts
{self, inputs, ...}: {
    flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; hostname = "laptop"; };
        modules = [
            self.nixosModules.laptopConf
            self.nixosModules.dvt
        ];
    };
}
