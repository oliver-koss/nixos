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
      oli_550 = "f002985a-bc2e-4861-a3bd-08eff0b663aa";
    };
 
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";
  };

}
