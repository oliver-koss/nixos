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
  ]);
}
