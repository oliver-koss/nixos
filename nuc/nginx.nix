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


}
