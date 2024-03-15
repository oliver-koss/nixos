{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "fritzbox-exporter";
  version = "latest";

  src = fetchFromGitHub {
    owner = "sberk42";
    repo = "fritzbox_exporter";
    rev = version;
    hash = "sha256-vXpWcEgi3YFeANMO1aezcHvYo0fvEkdwEJ1TJEeo+3c=";
  };

  vendorHash = "sha256-kI1P0sDp+tKtQe6apqbQzgRj/6pJ4ncEuQlZ8Cmix1w=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Fritz!Box Upnp statistics exporter for prometheus";
    homepage = "https://github.com/sberk42/fritzbox_exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ oliver-koss ];
    mainProgram = "fritzbox-exporter";
  };
}
