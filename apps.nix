{ pkgs, lib, ... }:

{
  services.cinnamon.apps.enable = true;

  # Gnome bits
  services.gnome.core-os-services.enable = true;
  services.gnome.core-utilities.enable = true;
  services.gnome.core-shell.enable = true;
  services.gnome.games.enable = true;

  environment.systemPackages = (with pkgs; [
    prusa-slicer
    openscad
    element-desktop
    tdesktop
    libreoffice
    prismlauncher
    htop
    hypnotix
    rhythmbox
    darktable
    calibre
    prometheus
    nextcloud-client
  ]) ++ (with pkgs.gnome; [
    gnome-disk-utility
    gnome-tweaks
  ]);
}
