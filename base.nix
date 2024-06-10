{ inputs, config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./cachix.nix
  ];
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  users.users.oliver = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "incus-admin" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = splitString "\n"
      (builtins.readFile ./oliver.pub);
  };

  users.users.root.openssh.authorizedKeys.keys = splitString "\n"
    (builtins.readFile ./oliver.pub);

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.overlays = [(import ./overlay.nix) inputs.acme.overlay ];
  security.sudo.wheelNeedsPassword = false;

  networking.nftables.enable = true;

  mkg.mod = {
    yggdrasil = {
      enable = true;
      port = 15237;
      peers = [ "tcp://ygg.mkg20001.io:80" "tls://ygg.mkg20001.io:443" ];
    };
    firewall-ips = {
      enable = true;
      ips = [
        # laptop
        "200:8825:6543:5fbf:bf60:fbae:9266:b552"
        # servers
        "206:c97d:47a1:ff37:9cc6:df87:3c8a:3fd9"
      ];
    };
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [
    git
    mtr
    tcpdump
    htop
    neofetch
    p7zip
    ncdu
  ];

  services.netdata.enable = true;
}
