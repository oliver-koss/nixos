{ config, pkgs, lib, ... }:

with lib;

{
  systemd.services.pat = {
    path = with pkgs; [fritz-exporter];
#    script = "HOME=$STATE_DIRECTORY pat http"; #script welches läuft
    wantedBy = [ "multi-user.target"]; #Starte mit diesen Dienst, multi-user = Systemstart
    after = ["network.target"]; #Started nach diesem Dienst; requires = starte nur wenn das andere Läuft
    sessionVariables = {
      FRITZ_HOSTNAME = "192.168.178.1";
      FRITZ_USERNAME = "username";
      FRITZ_PASSWORD = "password";
    };
  };
environment.systemPackages = with pkgs; [fritz-exporter];
} #am Ende kein ; , da Datei eh aus
