{ pkgs, ... }: {
  imports = [
    ./mosquitto.nix
#    ./pufferpanel.nix
#    ./calibre-web.nix
#    ./kavita.nix
    ./immich.nix
    ./rdp.nix
    ./slsk.nix
  ];

  systemd.services.mount-boot = {
    startAt = "daily";
    serviceConfig = {
      ExecStart = "${pkgs.mount}/bin/mount /boot";
    };
  };
}
