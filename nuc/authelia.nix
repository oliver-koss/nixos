{ lib, ...}: {

#networking.firewall.allowedTCPPorts = [ 9091 ];

  services.authelia.instances = {
    main = {
      enable = true;
      secrets.storageEncryptionKeyFile = "/var/lib/authelia-main/storageEncryptionKeyFile";
      secrets.jwtSecretFile = "/var/lib/authelia-main/jwtSecretFile";
      settings = {
        theme = "light";
        default_2fa_method = "totp";
        log.level = "debug";
        server.disable_healthcheck = true;
        authentication_backend.file = {
          path = "/var/lib/authelia-main/users.yml";
        };
        storage.local.path = "/var/lib/authelia-main/db.sqlite";
        session = {
          cookies = [
            {
              domain = "oliver-koss.at";
              authelia_url = "https://sso.oliver-koss.at";
              expiration = "3600";
              inactivity = "300";
            }
          ];
        };
        notifier.filesystem.filename = "/var/lib/authelia-main/emails.txt";
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "*.oliver-koss.at";
              policy = "one_factor";
            }
          ];
        };
      };
    };
  };
}
