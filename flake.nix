{
  description = "NixOS system for DVT";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    zapp.url = "github:zsa/zapp";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      home-manager,
      zapp,
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
            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  (final: prev: {
                    auto-cpufreq = pkgsUnstable.auto-cpufreq;
                  })
                ];
              };
              # I want to use latest auto-cpufreq
              disabledModules = [ "services/hardware/auto-cpufreq.nix" ];
              imports = [
                "${nixpkgs-unstable}/nixos/modules/services/hardware/auto-cpufreq.nix"
              ];
            }

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
            # ZSA's CLI flashing tool (https://github.com/zsa/zapp)
            zapp.nixosModules.default
            { programs.zapp.enable = true; }
          ];
        };
    in
    {
      nixosConfigurations.laptop = mkSystem "laptop" "dvt" "DVT-on-ROG";
      nixosConfigurations.desktop = mkSystem "desktop" "dvt" "DVT-on-Master";
      # TODO: I need to migrate my desktop to use disko and delete this host
      nixosConfigurations.desktop-disko = mkSystem "desktop-disko" "dvt" "DVT-on-Master";
      nixosConfigurations.media-desktop = mkSystem "media-desktop" "party" "DVTs-Party";
    };
}
