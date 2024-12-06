{ pkgs, ... }: {
  imports = [
    ../misc/maciej.nix
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens3";
    address = [
      "2a09:7c47:0:a::1/32"
      "91.207.183.126/24"
    ];
    routes = [
      { routeConfig.Gateway = "91.207.183.1"; }
      { routeConfig.Gateway = "2a09:7c47::1"; }
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "pq-vpn";
  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.useDHCP = false;
  networking.useNetworkd = true;
}
