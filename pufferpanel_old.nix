{ pkgs, lib, ... }:

with lib;

  {
  config = {
    services.nginx.virtualHosts = {
      "panel.oliver-koss.at" = {
        enableACME = true;
        forceSSL = true;
      };
    };

    services.pufferpanel = {
      enable = true;
      environment = {
        PUFFER_WEB_HOST = "0.0.0.0:8080";
      };
    };

#  services.sso.server = "";
#  services.sso.enable = false;

  networking.firewall.allowedTCPPorts =  [ 8080 443 ];

  };
  }
