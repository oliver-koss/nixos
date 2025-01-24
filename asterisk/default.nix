{ config, lib, pkgs, ... }:

with lib;

let
  r = file: builtins.readFile file;
  p = ./.;
  files = filterAttrs (key: value: hasSuffix ".conf" key) (builtins.readDir p);
  confFiles = mapAttrs (key: value: r "${p}/${key}") files;
in
{

  networking.firewall.allowedTCPPorts = [ 5060 ];

  services.asterisk = {
    enable = true;
    inherit confFiles;
  };
}
