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
  };

}
