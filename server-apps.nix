{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    speedtest-cli
    wget
    prometheus
    prometheus-node-exporter
    pufferpanel
    redis
    docker-compose
    asterisk
    cloudlog
    nload
    wget
    iftop
    iotop
    speedtest-cli
  ]);

  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = true;
    };
  };
}
