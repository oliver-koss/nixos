# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

with lib;

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./base.nix
      ./apps.nix
      ./funk.nix
      ./wine.nix
      ./pat.service.nix
      ./misc/builder.nix
      ./node_exporter.service.nix
      ./gpu.nix
      ./incus.nix
    ];

  services.wordpress.sites."kai" = {};

  systemd.services.pat.wantedBy = mkForce [];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.netbootxyz.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  boot.loader.systemd-boot.extraEntries."windows.conf" = ''
    title   Windows
    linux   /EFI/Microsoft/Boot/bootmgfw.efi
  '';

  networking.hostName = "oliver-nix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  virtualisation.incus.enable = true;
  virtualisation.incus.ui.enable = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


  services.xserver = {
    desktopManager.gnome.enable = true;
#    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

#  services.xserver.displayManager.sddm.enable = true;
#  services.xserver.desktopManager.plasma5.enable = true;
  programs.ssh.askPassword = pkgs.lib.mkForce "pkgs.plasma5.ksshaskpass.out/bin/ksshaskpass";

  # allow building pi stuffs on laptop
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
   elisa
   gwenview
   okular
   oxygen
   khelpcenter
   konsole
   plasma-browser-integration
   print-manager
 ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  xdg.portal.enable = true;
  hardware.pulseaudio.enable = mkForce false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
  hardware.bluetooth = {
    enable = true;
    settings.general.experimental = true;
    };

  programs.steam.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.oliver = {
  #  isNormalUser = true;
  #  extraGroups = [ "dialout" ];
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    google-chrome
    wsjtx
    git
    gedit
    pulsar
    yaru-theme
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

              nixpkgs.config.permittedInsecurePackages = [
                "pulsar-1.114.0"
                "pulsar-1.109.0"
                "pulsar-1.117.0"
                "googleearth-pro-7.3.4.8248"
                "python-2.7.18.8"
		"clion-2024.1"
                "python3.12-youtube-dl-2021.12.17"
                "temurin-bin-20.0.2"
                "googleearth-pro-7.3.6.9796"
              ];

#kdeconnect
  programs.kdeconnect.enable = true;

#prometheus service
  services.prometheus = {
    enable   = true;
    port     = 9090;
    configText = "
      global:
        scrape_interval: 10s

      scrape_configs:
        - job_name: 'prometheus'
          scrape_interval: 5s
          static_configs:
          - targets: ['localhost:9100']
        - job_name: 'ESP32'
          scrape_interval: 5s
          static_configs:
          - targets: ['192.168.43.31']
    ";
  };
#  hardware.printers = {
#  ensurePrinters = [
#    {
#      name = "EOS2-300-nix";
#      location = "Home";
#      deviceUri = "usb://cab/EOS2/300?serial=35320090038";
#      model = "/etc/nixos/cab_EOS2_300.ppd";
#    }
#  ];
#};
  boot.supportedFilesystems = [ "ntfs" ];

  networking.firewall.allowedTCPPorts =  [ 5060 5062 ];

  virtualisation.docker.enable = true;

  services.pcscd.enable = true;

}
