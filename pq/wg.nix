{ config, pkgs, lib, ... }:
let
  inherit (config.pq) ipv4 ipv6 privateIPv4 clients interface;
in with lib; {
  imports = [
    ./options.nix
    ./values.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;

    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;

    # allow IPv6 addrs to directly go out
    "net.ipv6.conf.all.proxy_ndp" = "1";
  };

  networking.firewall.allowedUDPPorts = [ 1111 51413 ];
  networking.firewall.allowedTCPPorts = [ 51413 ];
  networking.firewall.trustedInterfaces = [ "wg0" ];
  networking.firewall.filterForward = true;
  networking.firewall.extraForwardRules = ''
    iifname { "wg0", "${interface}" } oifname { "wg0", "${interface}" } accept
  '';

  systemd.services.ndp-proxy = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.callPackage ./ndp {}}/bin/ndp-proxy -i ${interface} -m ${toString ipv6.prefixLength} -n ${ipv6.prefix}";
    };
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "${privateIPv4.prefix}1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 1111;

      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/var/wg-priv";

      peers = (mapAttrsToList (key: cfg: {
        publicKey = cfg.publicKey;
        allowedIPs = [ "${privateIPv4.prefix}${toString cfg.id}/32" "${ipv6.prefix}${toString cfg.id}/128" ];
      }) clients);
    };
  };

  networking.nftables.tables.tznat = {
    family = "inet";
    content = ''
      chain POSTROUTING {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr ${privateIPv4.prefix}0/24 oifname "${interface}" masquerade
      }

      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
        iifname "${interface}" ip6 daddr ${ipv6.prefix}${ipv6.suffix} udp dport 500-1024 udp dport != 1111 redirect to :1111
        ${concatMapStringsSep "\n" (cfg: if cfg.portsV4 != [] then ''
          ip daddr ${ipv4} tcp dport { ${concatMapStringsSep ", " (port: toString port) (cfg.portsV4)} } dnat to ${privateIPv4.prefix}${toString cfg.id}
          ip daddr ${ipv4} udp dport { ${concatMapStringsSep ", " (port: toString port) (cfg.portsV4)} } dnat to ${privateIPv4.prefix}${toString cfg.id}
        '' else "") (attrValues clients)}
      }
    '';
  };

  services.resolved.extraConfig = ''
    DNSStubListenerExtra=${privateIPv4.prefix}1
    DNSStubListenerExtra=${ipv6.prefix}${ipv6.suffix}
  '';

  networking.firewall.extraInputRules = ''
    ip saddr ${privateIPv4.prefix}0/24 tcp dport 53 accept
    ip saddr ${privateIPv4.prefix}0/24 udp dport 53 accept
    ip6 saddr ${ipv6.prefix}/${toString ipv6.prefixLength} tcp dport 53 accept
    ip6 saddr ${ipv6.prefix}/${toString ipv6.prefixLength} udp dport 53 accept
  '';

  environment.systemPackages = with pkgs; [ ipcalc ];
}
