{ lib, ... }:

with lib;

{
  services.transmission = {
    enable = true;

    openFirewall = true;
    openRPCPort = true;
    openPeerPorts = true;

    credentialsFile = "/var/lib/secrets/transmission/settings.json";

    settings = {
      download-dir = "/storage/Torrents";
      watch-dir = "/storage/Incoming";
      watch-dir-enabled = true;
      rpc-bind-address = "::";
      incomplete-dir = "/storage/Downloading";
      # spusu 1tb (~700gb for torrent) limit
      # speed-limit-up = 1618;
      # speed-limit-up-enabled = true;
    };
  };

  systemd.services.transmission.serviceConfig = {
    BindPaths = mkForce [ "/var/lib/transmission/.config/transmission-daemon" "/storage" "/run" ];
    BindReadOnlyPaths = mkForce [ "/nix/store" "/etc" ];
  };

  torrentNS = [ "transmission" ];
}
