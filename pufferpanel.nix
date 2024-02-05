{ pkgs, lib, ... }:

with lib;

{
  config = {
    services.nginx.virtualHosts = {
      "panel.oliver-koss.at" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:8080";
      };
    };

    services.pufferpanel = {
      enable = true;
      environment = {
        PUFFER_WEB_HOST = "localhost:8080";
	      PUFFER_PANEL_EMAIL_USERNAME = "Oli_550";
      };
    };

    networking.firewall.allowedTCPPorts =  [ 8080 443 ];
  };
}
