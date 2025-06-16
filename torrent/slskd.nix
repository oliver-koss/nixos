let
  ports = [ 54015 54016 ];
in
{
  services.slskd = {
    enable = true;
    environmentFile = "/home/maciej/slskd";
    settings = {
      shares = {
        directories = [ "/storage/Sonarr" "/storage/Radarr" ];
      };
      global = {
        download = {
          slots = 2;
        };
        upload = {
          slots = 5;
          speed_limit = 1200;
        };
      };
      flags = {
        force_share_scan = true;
      };
      rooms = [ "MOVIES" "! ! LGBTQ+ ! !" "+Autism+" "! meow chat :3" ];      
      soulseek = {
        listen_port = 54015;
        description = "Movies and Series, German & English";
      };
    };
    domain = "slsk.oliver-koss.at";
  };

  networking.firewall.allowedTCPPorts = ports;
  networking.firewall.allowedUDPPorts = ports;

  torrentNS = [ "slskd" ];
}
