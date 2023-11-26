{ config, pkgs, lib, ... }:

with lib;

{
  nix.buildMachines = [
  {
    hostName = "aarch64.mkg20001.io";
    system = "aarch64-linux";
    protocol = "ssh-ng";
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
   }
 ];

 nix.distributedBuilds = true;
 # optional, useful when the builder has a faster internet connection than yours
 nix.extraOptions = ''
   # enable builders to use stuff from cache, not local
   builders-use-substitutes = true
   # actually enable
   builders = @/etc/nix/machines
 '';
}
