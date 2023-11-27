{ config, pkgs, lib, ... }:

with lib;

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.oliver = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = splitString "\n"
      (builtins.readFile ./oliver.pub);
  };

  users.users.root.openssh.authorizedKeys.keys = splitString "\n"
    (builtins.readFile ./oliver.pub);

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.overlays = [(import ./overlay.nix)];
  security.sudo.wheelNeedsPassword = false;

  networking.nftables.enable = true;

  mkg.mod = {
    yggdrasil = {
      enable = true;
      port = 15237;
      peers = [ "tcp://ygg.mkg20001.io:80" "tls://ygg.mkg20001.io:443" ];
    };
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];
}
