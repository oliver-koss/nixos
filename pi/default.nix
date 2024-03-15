{
  imports = [
    ./nginx.nix
    ./rar.nix
    ./transmission.nix
  ];

  security.acme.distributor-server = "https://acme.s.xeredo.it";
  security.acme.distributor-token = "esti75v4kzb3i5viznw3it5w4zv5j3wi5v";
}
