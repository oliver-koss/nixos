{ config, pkgs, ... }:
{
    services.prometheus = {
        enable  = true;
        port    = 9090;
        scrapeConfigs = [
            {
                job_name = "node";
                static_configs = [{
                    targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
                }];
            }
        ];
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
        http_port = 3000;
        # Grafana needs to know on which domain and URL it's running
#        domain = "your.domain";
#        root_url = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
#        serve_from_sub_path = true;
        };
    };
    security = {
      adminUser = "admin";
    };
    };

}
