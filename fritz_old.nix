{ config, pkgs, lib, ... }:

with lib;

{
  services.prometheus.exporters.fritzbox = {
    enable = true;
#    gatewayAdress = "192.168.178.1";
    extraFlags = {
      FRITZ_HOSTNAME = "192.168.178.1";
#      FRITZ_USERNAME = "username";
      };
    };
}
