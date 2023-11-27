{ config, pkgs, lib, ... }:

let
  url = "grafana.oliver-koss.at";
in
{
  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    domain = url;
    rootUrl = "https://" + url;
    protocol = "socket";
    security = {
      adminUser = "admin";
    };
    settings = {
      /* "auth.anonymous" = {
        enabled = true;
        org_name = "Funkfeuer Graz";
        org_role = "Viewer";
        hide_version = true;
      }; */
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    upstreams.grafana.servers."unix:/${config.services.grafana.socket}" = {};
    virtualHosts.${url} = {
      root = config.services.grafana.staticRootPath;
      enableACME = true;
      forceSSL = true;
      locations."/".tryFiles = "$uri @grafana";
      locations."@grafana".proxyPass = "http://grafana";
    };
  };

  users.users.nginx.extraGroups = [ "grafana" ];
}
