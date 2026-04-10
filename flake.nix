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
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    mkSystem = machine: user: hostname: nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs pkgsUnstable hostname;};
      modules = [
        { nixpkgs.config.allowUnfree = true; }

        ./hosts/${machine}/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs pkgsUnstable machine;
            };
            users.${user} = ./users/${user}/home.nix;
          };
        }
      ];
    };
  in {
    nixosConfigurations.laptop = mkSystem "laptop" "dvt" "DVT_on_ROG";
  };
}
