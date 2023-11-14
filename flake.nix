{
  description = "My nix configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    np.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixos, np, disko, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = import np {
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

        modules = [
          ./home-manager/root.nix
          ./home-manager/mail.nix
          homeModules.ayumprofile
          homeModules.ayumsecrets
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
      homeConfigurations."me" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home-manager/me.nix
        ];
      };
      nixosConfigurations."dev" = let
        hardwareConfiguration = ./nixos/hardware/generic-vps.nix;
        np = pkgs;
      in
        nixos.lib.nixosSystem {
          specialArgs = { inherit inputs hardwareConfiguration np; };
          modules = [
            disko.nixosModules.disko
            # { disko.devices.disk.disk1.device = "/dev/vda"; }
            ./nixos/dev/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true; # makes hm use nixos's pkgs value
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs pkgs; }; # allows access to flake inputs in hm modules
              home-manager.users.root.imports = [
                ./home-manager/root.nix
                homeModules.ayumprofile
                homeModules.ayumsecrets
              ];
            }
          ];
        };
    };
}
