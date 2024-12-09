{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "open-starbound";
  version = "0.0.2-dev";

  src = fetchFromGitHub {
    owner = "OpenStarbound";
    repo = "OpenStarbound";
    rev = "v${version}";
    hash = "sha256-anpTjlxa8J5wwJWVO3/Ve1KFomcK7vXiSji8p490u2Q=";
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "";
    homepage = "https://github.com/OpenStarbound/OpenStarbound.git";
    license = licenses.mit; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "open-starbound";
    platforms = platforms.all;
  };
}
