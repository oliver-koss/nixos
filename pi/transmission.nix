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
      rpc-bind-address = "200:5128:b507:a7c8:2ca3:599b:3bb:40ab";
      incomplete-dir = "/storage/Downloading";
    };
  };
}
