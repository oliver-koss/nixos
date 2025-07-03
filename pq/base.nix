{ pkgs, lib, ... }: {
  imports = [
    ../misc/maciej.nix
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "e*";
    address = [
      "2a11:3c01:0:d::1/32"
      "77.91.100.170/24"
    ];
    routes = [
      { routeConfig.Gateway = "77.91.100.1"; }
      { routeConfig.Gateway = "2a11:3c01::1"; }
    ];
  };

  users.users.root.initialPassword = "helloworld1984";

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  networking.hostName = "pq-vpn";
  system.stateVersion = "25.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.useDHCP = false;
  networking.useNetworkd = true;

  system.userActivationScripts = { wgStub = {
      text = ''
        ${pkgs.coreutils}/bin/touch /var/wg-priv
      '';
      deps = [];
    };
  };

}
