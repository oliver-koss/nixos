{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wine
    wineWowPackages.stable
    winetricks
    (wine.override { wineBuild = "wine64"; })
  ];
}
