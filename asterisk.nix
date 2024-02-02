{ config, lib, pkgs, ... }:
{
  services.asterisk = {
    enable = true;
    confFiles = {
      
    };
  };
}
