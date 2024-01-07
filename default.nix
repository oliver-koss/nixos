let
  pkgs = import <nixpkgs> {};
in
with pkgs;
{
qlog = qt6Packages.callPackage ./qlog.nix {};
pat = callPackage ./pat.nix {};
ardopc = callPackage ./ardopc.nix {};
ardopc-init = callPackage ./ardopc-init.nix {};
status = callPackage ./lcd-status.nix {};
m365py = python3.callPackage ./m365.nix {};
}
