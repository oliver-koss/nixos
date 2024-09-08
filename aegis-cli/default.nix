{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "aegis-cli";
  version = "unstable-2024-09-08";

  src = fetchFromGitHub {
    owner = "mkg20001";
    repo = "aegis-cli";
    rev = "6487a7dedaf8023f3fee9e9a174ba1b6b6d068c7";
    hash = "sha256-ovN2h0sSyUgCrUq6ZAg7Ri6k2qko3cebdCoLhCzueWU=";
  };

  vendorHash = "sha256-gvjfLhAA7XaamEge/ZO/6Q5RbBNAigYft7JI16IJ+N8=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Terminal User interface to generate 2FA from Aegis' json file";
    homepage = "https://github.com/navilg/aegis-cli";
    license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aegis-cli";
  };
}
