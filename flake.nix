{
  description = "My home-manager configuration of root";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    np.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixos, np, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = np.legacyPackages.${system};
    in {
      homeConfigurations."root" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home-manager/root.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
      nixosConfigurations."dev.ayum.ru" = nixos.lib.nixosSystem {
        modules = [
          ./nixos/dev.ayum.ru.nix
        ];
      };
    };
}
