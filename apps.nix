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
    hypnotix
    rhythmbox
    darktable
    calibre
#    prometheus
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
    esptool
    gparted
    ipscan
    ffmpeg
    tartube
    openjdk8-bootstrap
    googleearth-pro
    arduino-ide #new IDE
    arduino #old IDE
    r3ctl
 #   tor-browser
    libglibutil
    stdenv
    poetry
    discord
    nanovna-saver
 #   minetest
    viking
    marble
    mediathekview
    audacity

    jetbrains.clion

    jetbrains.pycharm-community
#    jetbrains-toolbox
    twinkle
    vlc
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
#    blender
    jdownloader
    helvum
    pavucontrol
    transmission_3-gtk
    rpi-imager #raspberry pi imager
    ffmpeg
#    fritzbox-exporter
    screen
    dnsmasq
    putty
    uucp
    ppp
    glxinfo
    wireguard-tools
    kdenlive
    usbutils
    transmission-remote-gtk
    gpsbabel-gui #garmin-integration
#    zombietrackergps
    gnucash
    lutris
    jellyfin-media-player
    yubioath-flutter
    android-tools
#    chirp
    gnome-disk-utility
    gnome-tweaks
    pan
    python3
    foliate
  ]) ++ (with pkgs.gnomeExtensions; [
    appindicator
  ]) ++ (with pkgs.libsForQt5; [
    ksshaskpass
  ]) ++ (with pkgs.kdePackages; [
    qtwebengine
  ]);
}
