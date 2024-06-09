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

  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  services.nginx.virtualHosts = {
    "watch.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8096/";
      };
    };

    "transmission.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://10.0.7.2:9091/";
      };
    };

    "radarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:7878/";
      };
    };

    "sonarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8989/";
      };
    };

    "bazarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:6767/";
      };
    };

    "prowlarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:9696/";
      };
    };

    "jellyseerr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:5055/";
      };
    };

    "readarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8787/";
      };
    };

    "lidarr.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8686/";
      };
    };
  };

}
