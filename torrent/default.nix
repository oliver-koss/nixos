{
  imports = [
    ./nginx.nix
    ./rar.nix
    ./storage.nix
    ./transmission.nix
    ./sabnzbd.nix
  ];

              nixpkgs.config.permittedInsecurePackages = [
                "aspnetcore-runtime-wrapped-6.0.36"
                "aspnetcore-runtime-6.0.36"
                "dotnet-sdk-wrapped-6.0.428"
                "dotnet-sdk-6.0.428"
              ];

  security.acme.distributor-server = "https://acme.s.xeredo.it";
  security.acme.distributor-token = "esti75v4kzb3i5viznw3it5w4zv5j3wi5v";
}
