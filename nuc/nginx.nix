{ config, pkgs, lib, ... }:

with lib;

let
  h = a: a // {
    enableACME = true;
    forceSSL = true;
  };
in
{
  services.nginx.enable = true;

  services.nginx.enableReload = true;
  services.nginx.recommendedBrotliSettings = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.recommendedZstdSettings = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx.virtualHosts = {
    "immich.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:2283/";
      };
      extraConfig = ''
        client_max_body_size 100g;
      '';
    };
  };

  services.nginx.virtualHosts = {
    "usenet.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8080/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "yt.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8000/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "tubearch.mkg20001.io" = h {
      locations."/" = {
        proxyPass = "http://localhost:8333/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "panel.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:10000/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "read.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:5000/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "calibre.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8083/";
      };
      extraConfig = ''
        client_max_body_size 10g;
      '';

    };
  };

  services.nginx.virtualHosts = {
    "youtube.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:8945/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "aprsc.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:14502/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "aprsc-panel.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:14501/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "immich-nix.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:2383/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "git.oliver-koss.at" = h {
      extraConfig = ''
        client_max_body_size 10G;
      '';
      locations."/" = {
        proxyPass = "http://localhost:3000/";
      };
    };
  };


}
