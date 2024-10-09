{ pkgs, ... }: {
  fileSystems."/storage" =
    { device = "torrentz";
      fsType = "zfs";
    };

  systemd.services.hardlink-storage = {
    script = ''
      hardlink -v -c /storage
    '';
    startAt = "monthly";
    path = with pkgs; [ util-linux ];
  };
}
