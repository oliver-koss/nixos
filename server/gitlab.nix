{
  services.gitlab.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "gitlab.oliver-koss.at" = {
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };

}
