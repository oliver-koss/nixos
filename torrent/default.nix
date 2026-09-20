{
  imports = [
    ./nginx.nix
    ./rar.nix
    ./storage.nix
    ./transmission.nix
    ./sabnzbd.nix
    ./slskd.nix
  ];

              nixpkgs.config.permittedInsecurePackages = [
                "aspnetcore-runtime-wrapped-6.0.36"
                "aspnetcore-runtime-6.0.36"
                "dotnet-sdk-wrapped-6.0.428"
                "dotnet-sdk-6.0.428"
              ];

  security.acme.distributor-server = "https://acme.mkg20001.net";
  security.acme.distributor-token = "1234";
}
