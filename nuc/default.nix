{ pkgs, ... }: {
  imports = [
    ./mosquitto.nix
#    ./pufferpanel.nix
#    ./calibre-web.nix
#    ./kavita.nix
    ./immich.nix
    ./rdp.nix
    ./forgejo.nix
    ./ipv6.nix
    ./minecraft/mcsurvival.nix
    ./ygg-ra.nix
    ./prometheus.nix
  ];

  systemd.services.mount-boot = {
    startAt = "daily";
    serviceConfig = {
      ExecStart = "${pkgs.mount}/bin/mount /boot";
    };
  };

  services.openssh = {
#    openFirewall = true;
    ports = [ 22222 ];
    enable = true;
  };

}
