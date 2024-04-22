{ config, pkgs, lib, ... }:

with lib;

let
  h = a: a // {
    enableACME = false;
    forceSSL = false;
  };
in
{
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 4000 ];

  services.nginx.virtualHosts = {
    "immich.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:2283/";
      };
    };
  };
  services.nginx.virtualHosts = {
    "dash.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:4000/";
      };
    };
  };

}
