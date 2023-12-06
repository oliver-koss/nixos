{ config, pkgs, lib, ... }:

with lib;

{
options.services.nextcloud.config.openidConfig = mkOption { type = types.str; };

config = {
  services.nginx.virtualHosts = {
    "cloud.oliver-koss.at" = {
      enableACME = true;
      forceSSL = true;
    };
  };

  services.nextcloud = {
    enable = true;

#    package = mkForce pkgs.nextcloud26;
    config = {
#      dbtype = mkForce "sqlite";
    };

    hostName = "cloud.oliver-koss.at";
  };

  services.sso.server = "";
  services.sso.enable = false;

#  services.sso.baseUrl = "";
#  services.sso.realmUrl = "";

  /* for migrations only */

  # services.nextcloud.fromSnap = true;
  # services.nextcloud.migrating = false;
};
}
