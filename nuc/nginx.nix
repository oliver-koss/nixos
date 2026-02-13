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
        extraConfig = ''
          proxy_set_header Referer $http_referer;
        '';
      };
    };
  };

#  services.nginx.virtualHosts = {
#    "panel.oliver-koss.at" = h {
#      locations."/" = {
#        proxyPass = "http://localhost:10000/";
#      };
#    };
#  };

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

  services.nginx.virtualHosts = {
    "uptime.oliver-koss.at" = h {
      locations."/" = {
        proxyPass = "http://localhost:3001/";
      };
    };
  };

  services.nginx.virtualHosts = {
    "irc.oliver-koss.at" = h {
      locations."/" = {
        root = "/nix/store/v99rzys4sw68k8nrlp3q9jzgjrl5dbxv-gamja-1.0.0-beta.11";
      };
      locations."/socket/" = {
        proxyPass = "http://localhost:5011";
	extraConfig = ''
          proxy_read_timeout 600s;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

#  services.nginx.virtualHosts = {
#    "archive.oliver-koss.at" = h {
#      locations."/" = {
#        proxyPass = "http://localhost:3004/";
#      };
#    };
#  };


}
