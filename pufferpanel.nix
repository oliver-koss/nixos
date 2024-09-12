{ config, pkgs, lib, ... }:

with lib;

let
/*
javaDrv = filterAttrs (n: p: (match "jdk[0-9]+" n != null) && let
  res = builtins.tryEval (!p.meta.insecure);
in res.success and res.value) pkgs;
*/
  javaDrv = filterAttrs (n: p: let
    res = builtins.tryEval ((match "jdk[0-9]+" n != null) && !p.meta.insecure);
  in
    res.success and res.value) pkgs;
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

    systemd.services.pufferpanel = {
      path = javaBin;
      restartIfChanged = false;
    };

    # not necesairly required
    systemd.tmpfiles.rules = [
      "L /pufferpath - - - - ${pkgs.symlinkJoin { name = "pufferpath"; paths = config.systemd.services.pufferpanel.path; }}"
    ];

    networking.firewall.allowedTCPPorts =  [ 8080 443 ];
    networking.firewall.allowedTCPPortRanges = [ { from = 25000; to = 26000; } ];
  };
}
