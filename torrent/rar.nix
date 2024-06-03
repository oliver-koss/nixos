{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [ "sabnzbd" ];

  services.radarr.enable = true;
  services.sonarr.enable = true;
  services.bazarr.enable = true;
  services.prowlarr.enable = true;
  services.jellyseerr.enable = true;
  services.readarr.enable = true;
  services.lidarr.enable = true;
}
