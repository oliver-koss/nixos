{ config, pkgs, ... }:
{
    imports = [
    ./exporters.nix
    ];
    
    services.prometheus = {
        enable  = true;
        port    = 9090;
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
                  targets = [ "192.168.178.95" ];
                  labels.service = "Maciej";
                }
                {
                  targets = [ "192.168.178.96" ];
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
#        root_url = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
#        serve_from_sub_path = true;
        };
      security = {
        secret_key = "SW2YcwTIb9zpOOhoPsMm";
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

}
