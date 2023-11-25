{ config, pkgs, lib, ... }:

with lib;

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.oliver = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = splitString "\n"
      (builtins.readFile ./oliver.pub);
  };

  security.sudo.wheelNeedsPassword = false;
}
