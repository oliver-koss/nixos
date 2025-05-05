# more context: https://discourse.nixos.org/t/configuring-remote-desktop-access-with-gnome-remote-desktop/48023/4?u=mkg20001

/*
Run after install:

sudo systemctl restart gnome-remote-desktop.service
sudo grdctl --system rdp enable

sudo rm -rf ~gnome-remote-desktop/rdp-tls*
sudo -u gnome-remote-desktop winpr-makecert     -silent -rdp -path ~gnome-remote-desktop rdp-tls

sudo grdctl --system rdp set-tls-key /var/lib/gnome-remote-desktop/rdp-tls.key
sudo grdctl --system rdp set-tls-cert /var/lib/gnome-remote-desktop/rdp-tls.crt
sudo grdctl --system rdp set-tls-cert /var/lib/gnome-remote-desktop/rdp-tls.crt
sudo grdctl --system rdp set-tls-cert /var/lib/gnome-remote-desktop/rdp-tls.crt
sudo grdctl --system rdp set-tls-key /var/lib/gnome-remote-desktop/rdp-tls.key

sudo grdctl --system rdp set-credentials "name" "password"

sudo systemctl restart gnome-remote-desktop.service
sudo systemctl status gnome-remote-desktop.service

sudo grdctl --system rdp enable
sudo grdctl --system status
*/
{ pkgs, config, lib, ... }: {
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.autoSuspend = false;
  };
  environment.systemPackages = with pkgs; [
     pkgs.gnome-remote-desktop
     freerdp
  ];
  services.gnome.gnome-remote-desktop.enable = true;
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
  systemd.services.gnome-remote-desktop = {
    restartIfChanged = false;
    wantedBy = [ "graphical.target" ];
  };

  services.cinnamon.apps.enable = true;
  services.gnome.core-utilities.enable = true;
  services.gnome.core-shell.enable = true;
  services.gnome.core-os-services.enable = true;
}
