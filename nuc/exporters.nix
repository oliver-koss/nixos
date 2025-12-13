{ config, pkgs, ... }:
{
    services.prometheus.exporters = {
        fritz = {
            enable = true;
            settings = {
                devices = [
                    {
                        username = "fritzexporter_nuc";
                    }
                ];
                
            }
        };
    };
}
