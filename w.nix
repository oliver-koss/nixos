let
  pkgs = import <nixpkgs> {};
in
with pkgs;
libsForQt5.callPackage ./qlog.nix {}


