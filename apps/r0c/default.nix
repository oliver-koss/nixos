{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  name = "r0c";
  format = "misc";

  src = ./src;

  installPhase = ''
    install -D r0c.py -m 755 $out/bin/r0c
  '';
}
