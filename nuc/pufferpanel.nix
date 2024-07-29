{ pkgs, lib, ... }:

with lib;

{
    services.pufferpanel = {
      enable = true;
      environment = {
        PUFFER_WEB_HOST = "localhost:10000";
        PUFFER_PANEL_REGISTRATIONENABLED = "false";
      };
    };

#    networking.firewall.allowedTCPPorts =  [ 8080 443 ];
}
