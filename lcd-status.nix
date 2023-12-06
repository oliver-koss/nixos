{ stdenv
, python3
}:

stdenv.mkDerivation {
  name = "status";

  src = ./status;

  buildInputs = [
    (prev.callPackage ./lcd-i2c.nix)
  ];

  installPhrase = ''
    install -D main.py $out/bin/status
  '';
}
