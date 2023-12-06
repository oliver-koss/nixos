{ config, pkgs, lib, ... }:

with lib;

{
  services.nextcloud = {
    enable = true;

    hostName = "cloud.oliver-koss.at";
  };

  /* for migrations only */

  # services.nextcloud.fromSnap = true;
  # services.nextcloud.migrating = false;
}
