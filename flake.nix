{
  description = "My nix configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    np.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixos, nixpkgs, np, disko, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = import np {
        inherit system;
        config.allowUnfree = true;
      };
      oldpkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      homeModules = {
        ayumsecrets = import ./home-modules/ayumsecrets.nix;
        ayumprofile = import ./home-modules/ayumprofile.nix;
      };
    in {
      inherit homeModules;
      homeConfigurations."root" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit oldpkgs; };

        modules = [
          ./home-manager/root.nix
          ./home-manager/mail.nix
          homeModules.ayumprofile
          homeModules.ayumsecrets
        ];
      };
      homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit oldpkgs; };

        modules = [
          ./home-manager/common.nix
          {
            home.username = "user";
            home.homeDirectory = "/home/user";
          }
        ];
      };
      homeConfigurations."me" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit oldpkgs; };

        modules = [
          ./home-manager/me.nix
          homeModules.ayumprofile
          homeModules.ayumsecrets
        ];
      };
      nixosConfigurations."dev" = let
        hardwareConfiguration = ./nixos/hardware/generic-vps.nix;
      in
        nixos.lib.nixosSystem {
          specialArgs = { inherit inputs hardwareConfiguration pkgs oldpkgs; };
          modules = [
            disko.nixosModules.disko
            # { disko.devices.disk.disk1.device = "/dev/vda"; }
            ./nixos/dev/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true; # makes hm use nixos's pkgs value
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs pkgs oldpkgs; }; # allows access to flake inputs in hm modules
              home-manager.users.root.imports = [
                ./home-manager/root.nix
                homeModules.ayumprofile
                homeModules.ayumsecrets
              ];
            }
          ];
        };
      nixosConfigurations."home" = let
        hardwareConfiguration = ./nixos/home-hardware-configuration.nix;
      in
        nixos.lib.nixosSystem {
          specialArgs = { inherit inputs hardwareConfiguration pkgs oldpkgs; };
          modules = [
            ./nixos/home-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true; # makes hm use nixos's pkgs value
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs pkgs oldpkgs; }; # allows access to flake inputs in hm modules
              home-manager.users.root.imports = [
                ./home-manager/me.nix
                homeModules.ayumprofile
                homeModules.ayumsecrets
              ];
            }
          ];
        };
    };
}
