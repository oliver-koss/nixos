{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ardopc";
  version = "20210828";

  src = fetchFromGitHub {
    owner = "hamarituc";
    repo = "ardop";
    rev = version;
    hash = "sha256-OUw9spFTsQLnsXksbfl3wD2NyY40JTyvlvONEIeZyWo=";
  };

sourceRoot = "${srcardopc.name}/ARDOPC";

  meta = with lib; {
    description = "ARDOP (Amateur Radio Digital Open Protocol) TNC implementation by John Wiseman (GM8BPQ). Unofficial repository";
    homepage = "https://github.com/hamarituc/ardop/ARDOPC";
    # license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "ardopc";
    platforms = platforms.all;
  };
}
