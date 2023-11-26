let
  pkgs = import <nixpkgs> {};
in
with pkgs;
{qlog = qt6Packages.callPackage ./qlog.nix {};
pat = callPackage ./pat.nix {};
}
