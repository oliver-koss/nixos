{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wine
    wineWowPackages.stable
    winetricks
    wineWowPackages.staging
    (wine.override { wineBuild = "wine64"; })
  ];
}
