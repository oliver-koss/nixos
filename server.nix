# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, modulesPath, ... }:

{
  imports =
    [
      # Include the default lxd configuration.
      "${modulesPath}/virtualisation/lxc-container.nix"
      ./base.nix
      ./grafana.nix
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  security.sudo.wheelNeedsPassword = false;

  documentation.enable = true;
  documentation.nixos.enable = true;
  documentation.man.enable = true;

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  virtualisation.lxc.nestedContainer = true;
  networking.useNetworkd = true;

  networking.resolvconf.enable = false;
  networking.useHostResolvConf = false;

  networking.hostName = "oliver-server";

  system.stateVersion = "24.05"; # Did you read the comment?

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "oliver.koss06@gmail.com";
}
