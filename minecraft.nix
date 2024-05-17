{ config, pkgs, lib, ... }:

{
  services.minecraft-server = {
    enable = false;
    eula = true;
    declarative = true;
#    dataDir = "/var/lib/minecraft-server/justforfun";
    whitelist = {
      oli_550 = "f002985a-bc2e-4861-a3bd-08eff0b663aa";
    };
    serverProperties = {
      server-port = 25565;
      white-list = true;
      gamemode = "survival";
      motd = "Olivers Minecraft Server";
      max-players = 10;
      enable-rcon = false;
    };
  };
}
