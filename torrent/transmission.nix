{ config, pkgs, lib, ... }:

with lib;

{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

    # runs in the tz netns (see torrent/ns.nix); host firewall rules would be
    # dead weight, and would expose the RPC port if the netns ever failed to come up
    openFirewall = false;
    openRPCPort = false;
    openPeerPorts = false;

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
