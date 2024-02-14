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
    (python3.withPackages(ps: [
#      (python3.pkgs.callPackage ./ninebot {})
       ]))
    (writeShellScriptBin "ninebot" "exec python3 -m ninebot_ble \"$@\"")
    esptool
    gparted
    ipscan
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
    nanovna-saver
    minetest
    viking
    marble
    ncdu
    yt-dlp #youtube-dl
    mediathekview
    audacity
    jetbrains.clion
    jetbrains.pycharm-community
    twinkle
    vlc
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    blender
    jdownloader
    helvum
    pavucontrol
    pulsemixer
    torrential
  ]) ++ (with pkgs.gnome; [
    gnome-disk-utility
    gnome-tweaks
  ]);
}
