{
  description = "NixOS system for DVT";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pkgsUnstable = import nixpkgs-unstable { inherit system; };
  in {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs pkgs pkgsUnstable;};
      modules = [
        { nixpkgs.config.allowUnfree = true; }

        ./modules/hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs pkgs pkgsUnstable;
              hostname = "laptop";
            };
            users.dvt = import ./modules/_home/home.nix;
          };
        }
      ];
    };
  };
}
