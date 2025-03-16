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

  services.nginx.enableReload = true;
  services.nginx.recommendedBrotliSettings = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.recommendedZstdSettings = true;


#  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
#  networking.firewall.allowedUDPPorts = [ 443 ];

  services.nginx.virtualHosts = {
    "uptime.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:3001/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "kluse.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:2283/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "kluse.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:3000/";
      };
    };
  };

}
