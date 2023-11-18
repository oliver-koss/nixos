{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    prusa-slicer
  ];
}
