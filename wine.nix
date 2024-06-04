{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
#    wine64
    winetricks
    protonup-qt
#    (wine.override { wineBuild = "wine64"; })
  ];
}
