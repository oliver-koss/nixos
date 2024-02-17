{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    speedtest-cli
    hamlib
    wget
    sshfs
    prometheus
    prometheus-node-exporter
    #status
    (python3.withPackages(p: with p; [
      rpi-gpio2
      rplcd
      libgpiod
      #machine
      #pico-i2c-lcd #Unterstrich zu Bindestrich ersetzten und alles klein
    ]))
    (python3.pkgs.callPackage ./ninebot {})
  ]);
}
