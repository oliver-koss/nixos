{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # qLog
    wsjtx
    qdmr
    fldigi
  ];
}
