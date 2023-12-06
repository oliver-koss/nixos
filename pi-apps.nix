{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    speedtest-cli
    hamlib
    wget
    sshfs
    #status
    (python3.withPackages(p: with p; [
      rpi-gpio2
      lcd-i2c
      rplcd
      libgpiod
      #machine
      #pico-i2c-lcd #Unterstrich zu Bindestrich ersetzten und alles klein
    ]))
  ]);
}
