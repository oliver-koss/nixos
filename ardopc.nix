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

  prePatch = ''
    cd ARDOPC
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
})
