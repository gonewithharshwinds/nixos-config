{
  description = "Harsh's Battlemage Ship towards Caelestia Dots Flake";

  inputs = {
    # Core system
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # UI / Shell
    ags.url = "github:Aylur/ags/v1";

    # Antigravity (kept as capability, not authority)
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    antigravity-nix.inputs.nixpkgs.follows = "nixpkgs";

    affinity-nix = {
      url = "github:mrshmllow/affinity-nix";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Caelestia ecosystem
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
      ];
    };
  };
}
