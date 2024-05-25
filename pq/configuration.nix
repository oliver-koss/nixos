{ inputs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    inputs.disko.nixosModules.disko
    ./disko.nix
    ({
      _module.args.disks = [ "/dev/vda" ];
    })

    ../base.nix
    ../misc/maciej.nix
    ../misc/ygg-v4.nix

    ./wg.nix
   ];

  # boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  boot.tmp.cleanOnBoot = true;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens3";
    address = [
      "2a09:7c47:0:15::1/64"
      "45.144.31.173/24"
    ];
    routes = [
      { routeConfig.Gateway = "45.144.31.1"; }
      { routeConfig.Gateway = "2a09:7c47::1"; }
    ];
  };

  networking.hostName = "pq-vpn";
  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.useDHCP = false;
  networking.useNetworkd = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.rebootWindow.lower = "04:00";
  system.autoUpgrade.rebootWindow.upper = "06:00";
  system.autoUpgrade.flake = "github:oliver-koss/nixos/master";
}
