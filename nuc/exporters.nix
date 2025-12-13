{ config, pkgs, ... }:
{
    services.prometheus.exporters = {
        fritz = {
            enable = true;
            settings = {
                devices = [
                    {
                        name = "fritzbox_6850";
                        hostname = "192.168.178.1";
                        username = "metrics";
                        password_file = "/var/fritzexporter-key";

                    }
                ];
                
            };
        };
    };
}
