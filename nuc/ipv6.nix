{ config, pkgs, lib, ... }:

{
  networking.firewall = {
    allowedUDPPorts = [ 1111 ]; # Clients and peers can use the same port, see listenport
  };
  # Enable WireGuard
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    uplink0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.100.0.4/24" "2a01:4f8:c012:2caf:4000::2/128" ];
      listenPort = 1111; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/var/ipv6-key";

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = "Lza1JEFbllqCfUYNRM6fw6cLgsC/dw0jseGexC5QVUU=";

          # Forward ipv6 the traffic via VPN.
          allowedIPs = [ "::/0" ];

          # Set this to the server IP and port.
          # endpoint = "10.12.6.11:1111";
          endpoint = "128.140.56.86:1111";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
