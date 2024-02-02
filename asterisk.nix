{ config, lib, pkgs, ... }:
{
  services.asterisk = {
    enable = true;
    confFiles = {
      "./asterisk/extensions.conf"
    };
  };
}
