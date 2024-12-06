{ config, pkgs, lib, ... }: with lib; let
  ns = pkgs.writeShellScript "ns" (builtins.readFile ./ns.sh);
  resolv = pkgs.writeText "resolv.conf" ''
    nameserver 2a09:7c47:0:a::1
    nameserver 10.7.0.1
    options edns0
  '';
in {
  options = {
    torrentNS = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Services outgoing via torrent vpn";
    };
  };

  config = mkMerge [ {
    systemd.services.ns = {
      serviceConfig = {
        RemainAfterExit = true;
        ExecStartPre = "${ns} up";
        ExecStart = "${pkgs.coreutils}/bin/true";
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

    environment.systemPackages = with pkgs; [
      ipcalc
      wireguard-tools
      # debug
      iptraf-ng
      tcpdump
    ];

    system.build.torrentNSResolv = resolv;
  } {
    systemd.services = genAttrs config.torrentNS (_: {
      requires = [ "ns.service" ];
      after = [ "ns.service" ];
      serviceConfig.NetworkNamespacePath = "/var/run/netns/tz";
      serviceConfig.BindReadOnlyPaths = [ "${resolv}:/etc/resolv.conf" ];
    });
  } ];
}
