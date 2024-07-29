{ pkgs, lib, ... }:

with lib;

let
  javaDrv = filterAttrs (n: p: (match "jdk[0-9]+" n != null) && !p.meta.insecure) pkgs;
  javaBin = mapAttrsToList (name_: p: let 
    name = replaceStrings [ "jdk" ] [ "java" ] name_;
  in pkgs.runCommand name {} ''
    mkdir -p $out/bin
    ln -s ${p}/bin/java $out/bin/${name}
  '') javaDrv;
in
{
  config = {
    services.nginx.virtualHosts = {
      "panel.oliver-koss.at" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8080";
          proxyWebsockets = true;
        };
      };
    };

    services.pufferpanel = {
      enable = true;
      environment = {
        PUFFER_WEB_HOST = "localhost:8080";
        PUFFER_PANEL_REGISTRATIONENABLED = "false";
      };
    };

    systemd.services.pufferpanel.path = javaBin;

    networking.firewall.allowedTCPPorts =  [ 8080 443 ];
  };
}
