{ config, lib, pkgs, ... }:

with lib;

let
  authDomain = "auth.oliver-koss.at";

  # filled in from zitadel: internal org -> Internal project -> oauth2-proxy app
  clientID = "391667066869973096";

  # vhosts from torrent/nginx.nix and nuc/nginx.nix, for services that have no
  # OIDC of their own. they keep their proxyPass, they only get auth_request.
  protected = [
    "sonarr.oliver-koss.at"
    "radarr.oliver-koss.at"
    "lidarr.oliver-koss.at"
    "readarr.oliver-koss.at"
    "prowlarr.oliver-koss.at"
    "bazarr.oliver-koss.at"
    "transmission.oliver-koss.at"
    "slsk.oliver-koss.at"
    "usenet.oliver-koss.at"
    "calibre.oliver-koss.at"
    "dashboard.oliver-koss.at"
  ];
in
{
  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    oidcIssuerUrl = "https://id.oliver-koss.at";
    inherit clientID;

    # both are systemd credentials, never world readable
    clientSecretFile = "/etc/oauth2-proxy/client-secret";
    cookie.secretFile = "/etc/oauth2-proxy/cookie-secret";

    # one cookie for every *.oliver-koss.at vhost behind the proxy
    cookie.domain = ".oliver-koss.at";
    cookie.secure = true;

    redirectURL = "https://${authDomain}/oauth2/callback";
    httpAddress = "http://127.0.0.1:4180";

    # zitadel already decides who may sign in, so no mail filtering here
    email.domains = [ "*" ];

    reverseProxy = true;
    trustedProxyIP = [ "127.0.0.1/32" "::1/128" ];
    setXauthrequest = true;

    extraConfig = {
      # back-redirects to the protected vhost after login
      whitelist-domain = ".oliver-koss.at";
      # single provider, the "sign in with" interstitial adds nothing
      skip-provider-button = true;
    };
  };

  services.oauth2-proxy.nginx = {
    domain = authDomain;
    # "groups" is the flat role list added by the zitadel action of the same name
    virtualHosts = genAttrs protected (_: { allowed_groups = [ "core" ]; });
  };

  # the module only hangs /oauth2/ off this vhost, it still needs to exist
  services.nginx.virtualHosts.${authDomain} = {
    enableACME = true;
    forceSSL = true;
  };
}
