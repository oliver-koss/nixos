{ config, pkgs, lib, ... }:

with lib;

{
  systemd.services.node_exporter = {
    path = with pkgs; [prometheus-node-exporter];
    script = "HOME=$STATE_DIRECTORY node_exporter";
    wantedBy = [ "network.target"];
  };
environment.systemPackages = with pkgs; [prometheus-node-exporter];
}
