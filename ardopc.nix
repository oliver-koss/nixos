{ fetchFromGitHub
, lib
, makeWrapper
, pkg-config
, stdenv
, alsa-lib
, flrig
, hamlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ardopc";
  version = "20210828";

  src = fetchFromGitHub {
    owner = "hamarituc";
    repo = "ardop";
    rev = "20210828";
    hash = "sha256-OUw9spFTsQLnsXksbfl3wD2NyY40JTyvlvONEIeZyWo=";
  };

  sourceRoot = "${finalAttrs.src.name}/ARDOPC";

  installPhase = ''
    install -D ardopc $out/bin/ardopc
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    flrig
    hamlib
  ];

  meta = with lib; {
    description = "ARDOP (Amateur Radio Digital Open Protocol) TNC implementation by John Wiseman (GM8BPQ)";
    homepage = "https://github.com/hamarituc/ardop/ARDOPC";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oliver-koss ];
    mainProgram = "ardopc";
    platforms = platforms.all;
  };
})
