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

}
