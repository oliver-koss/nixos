{ config, lib, pkgs, ... }:
{
  services.asterisk = {
    enable = true;
    confFiles = {
      # config files go here
    };
  };
}
