{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    ncdu
    pulsemixer
    nix-init
    gh #github CLI Tool
    yt-dlp #youtube-dl
    aegis-cli
    mqttui
    mutt
    mutt-wizard
    calcurse
  ];
}
