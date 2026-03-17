{ lib, ...}: {

#networking.firewall.allowedTCPPorts = [ 9091 ];

services.authelia.instances = {

  main = {
    enable = false;
    secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
    secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
    settings = {
      theme = "light";
      default_2fa_method = "totp";
      log.level = "debug";
      server.disable_healthcheck = true;
      authentication_backend.file = {
        path = "/etc/authelia/users.yml";
      };
      storage.local.path = "/etc/authelia/db.sqlite";
      session = {
        domain = "sso.oliver-koss.at";
        expiration = "3600";
        inactivity = "300";
      };
      notifier.filesystem.filename = "/etc/authelia/emails.txt";
      access_control = {
        default_policy = "deny";
        rules = {
          domain = "*.oliver-koss.at";
          policy = "one_factor";
        };
      };
    };
  };

};

}
