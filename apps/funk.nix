{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    #(if pkgs ? qlog then pkgs.qlog else pkgs.qt6Packages.callPackage ./qlog.nix {})
    qlog
    wsjtx
    qdmr
    fldigi
    tqsl
    rtl-sdr
    sdrangel
    sdrpp
    pat
    hamlib_4
    qsstv
    xastir
    nanovna-saver
  ];
}
