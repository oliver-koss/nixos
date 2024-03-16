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
    fritz-exporter
    #status
    influxdb2-cli
    uucp #dial up
    ppp #dial up
    (python3.withPackages(p: with p; [
      #rpi-gpio2
      #rplcd
      #libgpiod
#      (python3.pkgs.callPackage ./ninebot {})
      #machine
      #pico-i2c-lcd #Unterstrich zu Bindestrich ersetzten und alles klein
      fritzconnection
      pyyaml
    ]))
    # (python3.pkgs.callPackage ./ninebot {})
  ]);
}
