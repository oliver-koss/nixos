{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    vscodium
    gcc
    gdb
    valgrind
    clang-tools
    pwndbg
    gnumake
    clang
    esptool
  ]);
}
