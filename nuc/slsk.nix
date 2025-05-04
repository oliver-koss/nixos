let
  ports = [ 54015 54016 ];
in
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    soulseekqt
  ];
  networking.firewall.allowedTCPPorts = ports;
  networking.firewall.allowedUDPPorts = ports;
}
