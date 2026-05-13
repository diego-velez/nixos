{
  description = "NixOS system for DVT";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      mkSystem =
        machine: user: hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs pkgsUnstable hostname; };
          modules = [
            { nixpkgs.config.allowUnfree = true; }

            ./hosts/${machine}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs pkgsUnstable machine;
                };
                backupFileExtension = "backup";
                users.${user} = ./users/${user}/home.nix;
              };
            }
            disko.nixosModules.disko
          ];
        };
    in
    {
      nixosConfigurations.laptop = mkSystem "laptop" "dvt" "DVT-on-ROG";
      nixosConfigurations.desktop = mkSystem "desktop" "dvt" "DVT-on-Master";
      # TODO: I need to migrate my desktop to use disko and delete this host
      nixosConfigurations.desktop-disko = mkSystem "desktop-disko" "dvt" "DVT-on-Master";
    };
}
