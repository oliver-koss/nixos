{ config, pkgs, lib, ... }:

with lib;

{
  systemd.services.fritzbox_exporter = {
    path = with pkgs; [fritzbox_exporter];
    script = "HOME=$STATE_DIRECTORY fritzbox_exporter -h"; #script welches läuft
    wantedBy = [ "multi-user.target"]; #Starte mit diesen Dienst, multi-user = Systemstart
    after = ["network.target"]; #Started nach diesem Dienst; requires = starte nur wenn das andere Läuft

#    serviceConfig = {
#      ExecStart = ''${pkgs.screen}/bin/screen '';
#    };
  };
environment.systemPackages = with pkgs; [fritzbox_exporter];


#fritz-exporter.sessionVariables = {
#  FRITZ_HOSTNAME = "192.168.178.1";
#  FRITZ_USERNAME = "username";
#  FRITZ_PASSWORD = "password";
#};

}
