{ config, pkgs, lib, ... }: with lib; let
  ns = pkgs.writeShellScript "ns" (builtins.readFile ./ns.sh);
in {
  options = {
    torrentNS = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Services outgoing via torrent vpn";
    };
  };

  config = mkMerge [ {
    boot.kernel.sysctl = {
      "net.ipv6.conf.all.forwarding" = true;
    };

    systemd.services.ns = {
      serviceConfig = {
        RemainAfterExit = true;
        ExecStart = "${ns} up";
        ExecStop = "${ns} down";
        RestartSec = 30;
        Restart = "always";
      };

      path = with pkgs; [
        iproute2
        wireguard-tools
        nftables
      ];

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };

    networking.nftables.tables.tznat = {
      family = "inet";
      content = ''
      	chain POSTROUTING {
      		type nat hook postrouting priority srcnat; policy accept;
          ip saddr 10.0.7.0/24 oifname "e*" masquerade
      		ip6 saddr fd07::/64 oifname "e*" masquerade
      	}
      '';
    };

    environment.systemPackages = with pkgs; [
      ipcalc
      wireguard-tools
    ];
  } {
    systemd.services = genAttrs config.torrentNS (_: {
      requires = [ "ns.service" ];
      serviceConfig.NetworkNamespacePath = "/var/run/netns/tz";
    });
  } ];
}
