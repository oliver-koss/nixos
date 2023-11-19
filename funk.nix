{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    (if pkgs ? qlog then pkgs.qlog else pkgs.qt6Packages.callPackage ./qlog.nix {})
    wsjtx
    qdmr
    fldigi
  ];
}
