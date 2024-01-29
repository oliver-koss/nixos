{
  description = "Oliver's NixOS config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:oliver-koss/nixpkgs/lcd-i2c";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    xnix.url = "git+https://git.xeredo.it/xeredo/xnix.git";
    xnix.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mkg-mod.url = "github:mkg20001/mkg-mod/master";
    mkg-mod.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, mkg-mod, xnix, ... }@inputs: rec {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      oliver-nix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          # > Our main nixos configuration file <
          ./config.nix
        ];
      };

      oliver-server = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          "${xnix}/defaults/services/sso.nix"
          "${xnix}/defaults/services/nextcloud.nix"
          # > Our main nixos configuration file <
          ./server.nix
        ];
      };

#      oliver-pi = nixpkgs.lib.nixosSystem {
#        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
#        modules = [
#          mkg-mod.nixosModules.yggdrasil
#          mkg-mod.nixosModules.firewall-ips
#          # > Our main nixos configuration file <
#          ./pi.nix
#        ];
#      };
    };

    legacyPackages.x86_64-linux = {
      all = nixpkgs.legacyPackages.x86_64-linux.releaseTools.aggregate {
        name = "all-devices";
        constituents = map (c: c.config.system.build.toplevel) (builtins.attrValues nixosConfigurations);
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
