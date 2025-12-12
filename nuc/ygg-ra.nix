{ inputs, pkgs, config, lib, ... }: {
  boot.kernel.sysctl = {
    # forwarding
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.radvd = {
    enable = true;
    config = ''
    interface enp3s0
    {
         AdvSendAdvert on;
         AdvDefaultLifetime 0;
         prefix 301:4d2c:6e2a:c6e5::/64 {
             AdvOnLink on;
             AdvAutonomous on;
         };
         route 200::/7 {};
    };
    '';
  };

  networking.firewall.extraForwardRules = ''
    ip6 saddr 300::/7 ip6 daddr 200::/7 accept
  '';
}
