{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    prusa-slicer
    element-desktop
    tdesktop
    libreoffice
    prismlauncher
  ]) ++ (with pkgs.gnome; [
    gnome-disk-utility
  ]);
}
