{ config, pkgs, lib, ... }:

with lib;

{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

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
      download-queue-enabled = false;
      peer-limit-global = 2000;
      peer-limit-per-torrent = 500;
      # spusu 1te (~700gb for torrent) limit
      speed-limit-up = 1618;
      speed-limit-up-enabled = true;
    };
  };

  systemd.services.transmission.serviceConfig = {
    BindPaths = mkForce [ "/var/lib/transmission/.config/transmission-daemon" "/storage" "/run" "/archive" ];
    BindReadOnlyPaths = mkForce [ "/nix/store" "/etc" "${config.system.build.torrentNSResolv}:/etc/resolv.conf" ];
  };

  torrentNS = [ "transmission" ];
}
