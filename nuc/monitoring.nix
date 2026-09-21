{ config, pkgs, ... }:
{
    imports = [
    ./exporters.nix
    ];
    
    services.prometheus = {
        enable  = true;
        port    = 9090;
        retentionTime = "365d";
        checkConfig = "syntax-only";
        remoteWrite = [
          {
            name = "victoriametris_nuc";
            url = "http://localhost:8428/api/v1/write";
          }
        ];
        scrapeConfigs = [
            {
                job_name = "node";
                static_configs = [{
                    targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
                }];
            }
            {
                job_name = "fritz";
                static_configs = [{
                    targets = [ "localhost:${toString config.services.prometheus.exporters.fritz.port}" ];
                }];
            }
            {
                job_name = "fronius-bkw3a";
                static_configs = [{
                    targets = [ "10.23.23.92:9081" ];
                }];
            }
            {
                job_name = "fronius-bkw3";
                static_configs = [{
                    targets = [ "10.23.23.92:9088" ];
                }];
            }
            {
                job_name = "shelly-openmetrics-exporter";
                basic_auth = {
                  username = "admin";
                  password_file = "/var/shelly_key";
                };
                metrics_path = "/probe";
                static_configs = [
                {
                  targets = [ "10.88.0.244" ];
                  labels.service = "Maciej";
                }
                {
                  targets = [ "10.88.0.245" ];
                  labels.service = "Oliver";
                }
                ];
                relabel_configs = [
                  {
                    source_labels = ["__address__"];
                    target_label = "__param_target";
                  }
                  {
                    source_labels = [ "__param_target" ];
                    target_label  = "instance";
                  }
                  {
                    target_label = "__address__";
                    replacement = "10.23.23.92:54901";
                  }
                ];
            }
            {
                job_name = "mkt";
                static_configs = [{
                    targets = [ "localhost:49090" ];
                }];
            }
            {
                job_name = "incus";
                metrics_path = "/1.0/metrics";
                scheme = "https";
                static_configs = [{
                    targets = [ "localhost:8443" ];
                }];
                tls_config = {
                  ca_file = "/var/lib/incus/server.crt";
                  cert_file = "/var/certs/incus/metrics.crt";
                  key_file = "/var/certs/incus/metrics.key";
                  server_name = "oliver-nuc";
                };
            }
            {
                job_name = "smartctl";
                static_configs = [{
                    targets = [ "localhost:9633" ];
                }];
            }

        ];
    };

    services.victoriametrics = {
      enable = true;
      retentionPeriod = "10y";
    };

    services.prometheus.exporters.node = {
        enable = true;
        port = 9000;
        listenAddress = "localhost";
        # For the list of available collectors, run, depending on your install:
        # - Flake-based: nix run nixpkgs#prometheus-node-exporter -- --help
        # - Classic: nix-shell -p prometheus-node-exporter --run "node_exporter --help"
        enabledCollectors = [
        "ethtool"   
        "softirqs"
        "systemd"
        "tcpstat"
        "wifi"
        ];

        extraFlags = [ "--collector.ntp.protocol-version=4" "--no-collector.mdadm" ];
    };

    services.grafana = {
    enable = true;
    settings = {
        server = {
        # Listening Address
        http_addr = "0.0.0.0";
        # and Port
        http_port = 3590;
        # Grafana needs to know on which domain and URL it's running
        domain = "grafana.oliver-koss.at";
        root_url = "https://grafana.oliver-koss.at/";
#        serve_from_sub_path = true;
        };
      security = {
        secret_key = "SW2YcwTIb9zpOOhoPsMm";
      };
      # zitadel: internal org -> internal project. the project requires a role
      # assignment to authenticate, so only members with "core" get this far.
      "auth.generic_oauth" = {
        enabled = true;
        name = "ZITADEL";
        client_id = "391667067222294632";
        client_secret = "$__file{/etc/grafana/oidc-secret}";
        # last scope pins the login to the internal org, without forcing the
        # @domain login suffix that the primary-domain scope would require
        scopes = "openid profile email urn:zitadel:iam:org:id:391663715017031784";
        auth_url = "https://id.oliver-koss.at/oauth/v2/authorize";
        token_url = "https://id.oliver-koss.at/oauth/v2/token";
        api_url = "https://id.oliver-koss.at/oidc/v1/userinfo";
        # "groups" is a flat role list, added by the zitadel action of the same name
        role_attribute_path = "contains(groups[*], 'core') && 'Admin' || 'Viewer'";
        allow_sign_up = true;
      };
    };
    };

    services.nginx.virtualHosts."grafana.oliver-koss.at" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
    };
    };

    services.prometheus.exporters.smartctl = {
      enable = true;
      devices = [
        "/dev/sda"
        "/dev/sdb"
        "/dev/sdc"
        "/dev/sdd"
      ];
    };
}
