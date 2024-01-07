let
  pkgs = import <nixpkgs> {};
in
with pkgs;
{
  ardopc = callPackage ./ardopc.nix {};
  ardopc-init = callPackage ./ardopc-init.nix {};
  status = callPackage ./lcd-status.nix {};
  m365py = python3.callPackage ./m365.nix {};
}
