{
  description = "Oliver's NixOS config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, ... }@inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      oliver-nix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          # > Our main nixos configuration file <
          ./config.nix
        ];
      };

      oliver-server = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          # > Our main nixos configuration file <
          ./server.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
 #   homeConfigurations = {
 #     # FIXME replace with your username@hostname
 #     "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
 #       pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
 #       extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
 #       # > Our main home-manager configuration file <
 #       modules = [ ./home-manager/home.nix ];
 #     };
 #   };
  };
}
