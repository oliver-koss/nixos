{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.radarr.enable = true;
  services.sonarr.enable = true;
  services.bazarr.enable = true;
  services.prowlarr.enable = true;
}
