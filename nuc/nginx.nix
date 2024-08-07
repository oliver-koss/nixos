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

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx.virtualHosts = {
    "immich.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:2283/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "usenet.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8080/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "yt.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8000/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "tubearch.mkg20001.io" = h {
      locations."/" = {
        proxyPass = "http://localhost:8333/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "panel.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:10000/";
      };
    };
  };


}
