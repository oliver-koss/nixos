{ config, pkgs, lib, ... }:

with lib;

{
  systemd.services.pat = {
    path = with pkgs; [pat];
    script = "HOME=$STATE_DIRECTORY pat http"; #script welches läuft
    wantedBy = [ "multi-user.target"]; #Starte mit diesen Dienst, multi-user = Systemstart
    after = ["network.target"]; #Started nach diesem Dienst; requires = starte nur wenn das andere Läuft
    serviceConfig = {
      StateDirectory = "pat";
    };
  };
environment.systemPackages = with pkgs; [pat];
} #am Ende kein ; , da Datei eh aus
