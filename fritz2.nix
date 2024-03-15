{ config, pkgs, lib, ... }:

with lib;

{
  systemd.services.fritz-exporter = {
    path = with pkgs; [fritz-exporter];
  #  script = "HOME=$STATE_DIRECTORY fritz_exporter"; #script welches läuft
    wantedBy = [ "multi-user.target"]; #Starte mit diesen Dienst, multi-user = Systemstart
    after = ["network.target"]; #Started nach diesem Dienst; requires = starte nur wenn das andere Läuft
    environment = {
      FRITZ_HOSTNAME = "192.168.178.1";
      FRITZ_USERNAME = "username";
      FRITZ_PASSWORD = "password";
    };
    serviceConfig = {
      ExecStart = ''${pkgs.screen}/bin/screen '';
    };
  };
environment.systemPackages = with pkgs; [fritz-exporter];


#fritz-exporter.sessionVariables = {
#  FRITZ_HOSTNAME = "192.168.178.1";
#  FRITZ_USERNAME = "username";
#  FRITZ_PASSWORD = "password";
#};

}
