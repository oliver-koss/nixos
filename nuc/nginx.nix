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

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx.virtualHosts = {
    "immich.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:2283/";
      };
    };
  };
}
