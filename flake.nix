{
  description = "Oliver's NixOS config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:oliver-koss/nixpkgs/lcd-i2c";
#    xstarbound.url = "github:xstarbound/xstarbound";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    xnix.url = "git+https://git.xeredo.it/xeredo/xnix.git";
    xnix.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mkg-mod.url = "github:mkg20001/mkg-mod/master";
    mkg-mod.inputs.nixpkgs.follows = "nixpkgs";

    acme.url = "git+https://git.xeredo.it/xeredo/nixdeploy/acme-distributor";
    acme.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, mkg-mod, xnix, acme, ... }@inputs: rec {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      oliver-nix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          nixos-hardware.nixosModules.common-cpu-amd
          # nixos-hardware.nixosModules.common-gpu-nvidia
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

      oliver-pi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          acme.nixosModules.acme-shim
          # > Our main nixos configuration file <
          ./pi.nix
        ];
      };

      oliver-nuc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          nixos-hardware.nixosModules.common-cpu-intel
          acme.nixosModules.acme-shim
          # > Our main nixos configuration file <
          ./nuc.nix
        ];
      };

      backup-nuc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          nixos-hardware.nixosModules.common-cpu-intel
          acme.nixosModules.acme-shim
          # > Our main nixos configuration file <
          ./backup-nuc.nix
        ];
      };


      pq-vpn = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          mkg-mod.nixosModules.yggdrasil
          mkg-mod.nixosModules.firewall-ips
          nixos-hardware.nixosModules.common-cpu-intel
          acme.nixosModules.acme-shim
          # > Our main nixos configuration file <
          ./pq/configuration.nix
        ];
      };
    };

    legacyPackages.x86_64-linux = {
      all = nixpkgs.legacyPackages.x86_64-linux.releaseTools.aggregate {
        name = "all-devices";
        constituents = map (c: c.config.system.build.toplevel) (builtins.attrValues nixosConfigurations);
      };
    };

    packages.x86_64-linux = {
      pq-iso = (nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          ./iso.nix
          ./pq/base.nix
        ];
      }).config.system.build.isoImage;
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
