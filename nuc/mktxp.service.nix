{ pkgs, ... }:

{
  systemd.services.mktxp = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.mktxp}/bin/mktxp --cfg-dir /var/mktxp export";
    };
    wantedBy = [ "multi-user.target"]; #Starte mit diesen Dienst, multi-user = Systemstart
  };
} #am Ende kein ; , da Datei eh aus
