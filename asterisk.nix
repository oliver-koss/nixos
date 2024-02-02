{ config, lib, pkgs, ... }:
{
  services.asterisk = {
    enable = true;
    confFiles =
      [
      ./asterisk/extensions.conf
      ./asterisk/pjsip.conf
      ./asterisk/sip.conf
      ];
  };
}
