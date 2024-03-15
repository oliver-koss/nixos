{ config, pkgs, lib, ... }:

with lib;

let
  h = a: a // {
    enableACME = true;
    forceSSL = true;
  };
in
{
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  services.nginx.virtualHosts = {
    "watch.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8096/";
      };
    };

    "radarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:7878/";
        basicAuth."torrent4ever" = "4baes89joa47eiz8b6vj87iab4ienb6tzhv4kejgtr7be4av4nwtjk";
      };
    };

    "sonarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8989/";
        basicAuth."torrent4ever" = "4baes89joa47eiz8b6vj87iab4ienb6tzhv4kejgtr7be4av4nwtjk";
      };
    };
  };

}
