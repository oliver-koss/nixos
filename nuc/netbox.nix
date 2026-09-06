{ config, pkgs, ... }: {

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    bind = "0.0.0.0:8001";
    secretKeyFile = "/var/lib/netbox/secret-key-file";
    # For netbox 4.5
    apiTokenPeppersFile = "/var/lib/netbox/api-token-peppers-file";
    settings = {
      # DEBUG = true;   # use this if you hit the CSRF error.
      ALLOWED_HOSTS = [ "netbox.oliver-koss.at" ];  # from proxyPass (below)
      CSRF_TRUSTED_ORIGINS = [ "http://__YOUR_HOSTNAME_HERE__" ];  # CSRF error fix
    };
  };

}
