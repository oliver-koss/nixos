{ pkgs, ... }: {
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
    iifname { "wg0", "ens3" } oifname { "wg0", "ens3" } accept
  '';

  systemd.services.ndp-proxy = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.callPackage ./ndp {}}/bin/ndp-proxy -i ens3 -m 64 -n 2a09:7c47:0:15::";
    };
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.7.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 1111;

      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/var/wg-priv";

      peers = [
        {
          # nuc
          publicKey = "7A+1fP6CXdSbkZv9qlPM4Ra+MMsLod6gOt4Q9pMFUBQ=";
          allowedIPs = [ "10.7.0.2/32" "2a09:7c47:0:15::2/128" ];
        }
        {
          # m
          publicKey = "xtzVc6vqJy4rx/ZY9uvCwDX/ftwPuC53lA9qvwT1KBs=";
          allowedIPs = [ "10.7.0.3/32" "2a09:7c47:0:15::3/128" ];
        }
        {
          # o
          publicKey = "hP5+a0KfPBT77JlIkrK352fxOe6QHQ82g2TH+I7/kyk=";
          allowedIPs = [ "10.7.0.4/32" "2a09:7c47:0:15::4/128" ];
        }
        {
          # n
          publicKey = "LZ/QSVEznNXicc1yrcNDtphpugUKOQahLEL3u7mXiTU=";
          allowedIPs = [ "10.7.0.5/32" "2a09:7c47:0:15::5/128" ];
        }
      ];
    };
  };

  networking.nftables.tables.tznat = {
    family = "inet";
    content = ''
      chain POSTROUTING {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.7.0.0/24 oifname "e*" masquerade
        ip6 daddr 2a09:7c47:0:15::1 udp dport 500-1024 udp dport != 1111 redirect to 1111
      }

      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
        ip daddr 45.144.31.173 tcp dport { 51413 } dnat to 10.7.0.2
        ip daddr 45.144.31.173 udp dport { 51413 } dnat to 10.7.0.2
      }
    '';
  };

  services.resolved.extraConfig = ''
    DNSStubListenerExtra=10.7.0.1
    DNSStubListenerExtra=2a09:7c47:0:15::1
  '';

  networking.firewall.extraInputRules = ''
    ip saddr 10.7.0.0/24 tcp dport 53 accept
    ip saddr 10.7.0.0/24 udp dport 53 accept
    ip6 saddr 2a09:7c47:0:15::/64 tcp dport 53 accept
    ip6 saddr 2a09:7c47:0:15::/64 udp dport 53 accept
  '';

  environment.systemPackages = with pkgs; [ ipcalc ];
}
