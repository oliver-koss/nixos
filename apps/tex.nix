{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    texliveFull

  #extensions
  ]) ++ (with pkgs.texlivePackages; [
    getmap
  ]);
}
