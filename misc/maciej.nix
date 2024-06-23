{ lib, ... }:

with lib;

{
  users.users.maciej = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "incus-admin" "docker" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = splitString "\n"
      (builtins.readFile ./maciej.pub);
  };
}
