{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    # @blocksort asc
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
