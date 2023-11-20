{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wine
    wineWowPackages.stable
    winetricks
    wineWowPackages.staging
  ];
}
