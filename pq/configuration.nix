{ inputs, modulesPath, lib, pkgs, ... }:

with lib;

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    inputs.disko.nixosModules.disko
    ./disko.nix
    ({
      _module.args.disks = [ "/dev/vda" ];
    })

    ../base.nix
    ../misc/ygg-v4.nix

    ./wg.nix
    ./base.nix
   ];

  # boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  boot.tmp.cleanOnBoot = true;

  services.netdata.enable = mkForce false;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.rebootWindow.lower = "04:00";
  system.autoUpgrade.rebootWindow.upper = "06:00";
  system.autoUpgrade.flake = "github:oliver-koss/nixos/master";

  # maybe fix disk stuff
  services.journald.storage = "volatile";

  environment.systemPackages = with pkgs; [ iptraf-ng ];
}
