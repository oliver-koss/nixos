{ config, pkgs, ... }:
{
    services.prometheus.exporters = {
        fritz = {
            enable = true;
        }
    };
}
