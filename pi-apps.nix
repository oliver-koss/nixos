{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    speedtest-cli
    hamlib
    wget
    sshfs
    prometheus
    prometheus-node-exporter
    ncdu
    wireguard-tools
    #status
    (python3.withPackages(p: with p; [
      #rpi-gpio2
      #rplcd
      #libgpiod
#      (python3.pkgs.callPackage ./ninebot {})
      #machine
      #pico-i2c-lcd #Unterstrich zu Bindestrich ersetzten und alles klein
    ]))
    # (python3.pkgs.callPackage ./ninebot {})
  ]);
}
