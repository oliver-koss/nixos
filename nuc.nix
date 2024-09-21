# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, config, pkgs, lib, modulesPath, ... }:

with lib;

{
  imports =
    [ # Include the results of the hardware scan.
      ./nuc/hardware-configuration.nix
      ./base.nix
      ./misc/maciej.nix
      ./misc/ygg-v4.nix
      ./torrent
      ./torrent/ns.nix
      ./nuc/nginx.nix
      ./nuc/wg.nix
      ./node_exporter.service.nix
      ./minecraft.nix
#      ./pi/kodi.nix
      ./nuc

    inputs.disko.nixosModules.disko
    ./nuc/disko.nix
    ({
      _module.args.disks = [ "/dev/disk/by-id/ata-Intenso_SSD_Sata_III_2022042201044" ];
    })

    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  services.docuum = {
    enable = true;
    threshold = "10 GB";
  };

#  services.transmission.enable = mkForce false;

  networking.hostId = "7f1b839f";

  networking.hostName = "oliver-nuc"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.wireless.enable = mkForce false;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 14d";

  system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;
  # system.autoUpgrade.rebootWindow.lower = "04:00";
  # system.autoUpgrade.rebootWindow.upper = "06:00";
  system.autoUpgrade.flake = "github:oliver-koss/nixos/master";

  boot.tmp.useTmpfs = true;

  # 1. enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      # vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };
  boot.kernelParams = [ "i915.enable_guc=2" ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = mkForce false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
#  hardware.bluetooth.enable = true;

  # started in user sessions.
  programs.mtr.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

  virtualisation.docker.enable = true;

  systemd.services.docker-iptables-fix = {
    path = with pkgs; [ iptables-nftables-compat ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for i in $(seq 1 100); do
        sleep 2s
        iptables -P FORWARD ACCEPT
        ip6tables -P FORWARD ACCEPT
      done
    '';
  };

  environment.systemPackages = with pkgs; [
    yt-dlp
    calibre
  ];

  services.prometheus.exporters.fritzbox = {
    enable = true;
    gatewayAddress = "192.168.178.1";
  };
  hardware.enableRedistributableFirmware = true;
}
