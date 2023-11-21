{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    wine64
    winetricks
    (wine.override { wineBuild = "wine64"; })
  ];
}
