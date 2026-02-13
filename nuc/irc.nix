{ pkgs, lib, ...}: {

  services.soju = {
    enable = true;
    hostName = "irc.oliver-koss.at";
#    listen = ["ircs://0.0.0.0:6697" "wss://localhost:5011"];
    listen = ["ircs://0.0.0.0:6697"];
    tlsCertificate = "/var/lib/acme/irc.oliver-koss.at/fullchain.pem";
    tlsCertificateKey = "/var/lib/acme/irc.oliver-koss.at/key.pem";
#    extraConfig = "
#      auth http https://irc.oliver-koss.at
#    ";
  };

  systemd.services.soju.serviceConfig.SupplementaryGroups = [ "nginx" ];

  environment.systemPackages = with pkgs; [
    gamja
  ];

  services.znc = {
    enable = false;
    mutable = false; # Overwrite configuration set by ZNC from the web and chat interfaces.
    useLegacyConfig = false; # Turn off services.znc.confOptions and their defaults.
    openFirewall = true; # ZNC uses TCP port 5000 by default.
  };

  services.znc.config = {
    LoadModule = [ "adminlog" "webadmin" ]; # Write access logs to ~znc/moddata/adminlog/znc.log. 
    User.oliver = {
      Admin = true;
      Pass.password = {
        Method = "sha256"; # Fill out this section
        Hash = "5a41799bd4a08e94124f686b694c31847546ba313de224157f16bed43dedda05";      # with the generated hash.
        Salt = "Rf*YNSVc2z0c!ZX/Gjsc";
      };
    };
  };

}
