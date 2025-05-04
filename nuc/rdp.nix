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
  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];

  services.cinnamon.apps.enable = true;
  services.gnome.core-utilities.enable = true;
  services.gnome.core-shell.enable = true;
  services.gnome.core-os-services.enable = true;
}
