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
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ util-linux ];
  };
}
