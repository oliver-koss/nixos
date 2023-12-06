{ pkgs, python3, ... }:

{
  systemd.services.status = {
    serviceConfig = {
      ExecStart = "/home/oliver/lcd/lcd_s.py";
    };
    wantedBy = [ "multi-user.target"]; #Starte mit diesen Dienst, multi-user = Systemstart
  };
} #am Ende kein ; , da Datei eh aus
