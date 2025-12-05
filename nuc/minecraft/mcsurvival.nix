{ pkgs, lib, ...}: {
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;
 
    package = pkgs.papermcServers.papermc-1_18_2;
    dataDir = "/mc/mcsurvival";
 
    serverProperties = {
      server-port = 25585;
      gamemode = "survival";
      difficulty = "easy";
      simulation-distance = 10;
      white-list = true;
    };
 
    whitelist = {
      vimjoyer = "3f96da12-a55c-4871-8e26-09256adac319";
    };
 
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";
  };

}
