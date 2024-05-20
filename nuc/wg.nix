{
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.64.0.3/32" "2a01:7e01:e003:28f3::/64" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 1111;

      mtu = 1400;

      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/var/wg-priv";

      peers = [
        {
          # server
          publicKey = "KRBWKp6OmGLEWJB9xyxZ/w7aI/Wdm9bYjvycxC7fjwk=";
          allowedIPs = [ "10.64.0.0/24" "::/0" ];
          endpoint = "6in4.mkg20001.io:1111";
        }
      ];
    };
  };
}
