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
#    hypnotix
    rhythmbox
    darktable
    calibre
    nextcloud-client
    gimp
    geogebra6
    filezilla
    (python3.withPackages(p: with p; [
      pyserial
    ]))
#    (python3.withPackages(ps: [
#      (python3.pkgs.callPackage ./ninebot {})
#      ]))
    (writeShellScriptBin "ninebot" "exec python3 -m ninebot_ble \"$@\"")
    gparted
    ipscan
    ffmpeg
#    tartube
    openjdk8-bootstrap
    googleearth-pro
#    arduino-ide #new IDE
#    arduino #old IDE
    r3ctl
    libglibutil
    stdenv
#    poetry
    discord
 #   minetest
    viking
#    mediathekview
    vlc
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    helvum
    pavucontrol
#    transmission_3-gtk
    rpi-imager #raspberry pi imager
    ffmpeg
    screen
    dnsmasq
    putty
#    uucp
    ppp
    glxinfo
    wireguard-tools
    kdenlive
    usbutils
    transmission-remote-gtk
#    gpsbabel-gui #garmin-integration
#    zombietrackergps
#    gnucash
    jellyfin-media-player
    android-tools
    gnome-disk-utility
#    gnome-tweaks
    pan
    python3
    foliate
    gnome-terminal
#    jetbrains.clion
    maxima
#    nheko
#    xstarbound
#    python312Packages.meshtastic
#    freecad
    ungoogled-chromium
    josm #OSM Editor
    minetest
    inkscape
    twinkle
    kicad
    sysstat
    vnstat
    transmission
    signal-desktop
    anydesk
  ]) ++ (with pkgs.gnomeExtensions; [
    appindicator
  ]) ++ (with pkgs.libsForQt5; [
    ksshaskpass
  ]) ++ (with pkgs.kdePackages; [
    qtwebengine
  ]);
}
