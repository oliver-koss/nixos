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
    gimp
    geogebra6
    filezilla
    python3
    esptool
    gparted
    ipscan
    youtube-dl
    ffmpeg
    tartube
    nix-init
    gh #github CLI Tool
    openjdk8-bootstrap
    googleearth-pro
    arduino
    r3ctl
    tor-browser
    libglibutil
    stdenv
    poetry
    discord
    python311Packages.bluepy
  ]) ++ (with pkgs.gnome; [
    gnome-disk-utility
    gnome-tweaks
  ]);
}
