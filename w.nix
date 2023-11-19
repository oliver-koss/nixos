let
  pkgs = import <nixpkgs> {};
in
with pkgs;
qt6Packages.callPackage ./qlog.nix {}


