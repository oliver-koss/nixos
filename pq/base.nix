{ pkgs, lib, ... }: {
  imports = [
    ../misc/maciej.nix
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "e*";
    address = [
      "2a09:7c47:0:4::1/32"
      "91.207.183.227/24"
    ];
    routes = [
      { routeConfig.Gateway = "91.207.183.1"; }
      { routeConfig.Gateway = "2a09:7c47::1"; }
    ];
  };

  users.users.root.initialPassword = "helloworld1984";

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  networking.hostName = "pq-vpn";
  system.stateVersion = "24.11";
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
