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

    # (NEW) Spicetify for that aesthetic Spotify client. Because standard Spotify is an eyesore.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # (NEW) Nix Index Database. Hooks into command-not-found so you never have to guess what package contains a binary ever again.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
        
        # (NEW) Injecting the nix-index module directly into the system so it's ready to go
        inputs.nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
