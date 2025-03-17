{
  imports = [
    ./nginx.nix
    ./uptime-kuma.nix
    ./pufferpanel.nix
  ];

  services.openssh = {
    openFirewall = true;
    ports = [ 22222 ];
  };
}
