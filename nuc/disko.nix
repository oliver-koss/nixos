{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNM0W809252B";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2000M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rtorrent";
              };
            };
          };
        };
      };
    };
    zpool = {
      rtorrent = {
        type = "zpool";
        options = {
          autotrim = "on";
          cachefile = "none";
          # defaults
          autoexpand = "on";
        };
        rootFsOptions = {
          normalization = "formC";
          canmount = "off";
        # defaults
          acltype = "posixacl";
        # mountpoint = "legacy";
          xattr = "sa";
          utf8only = "on";
        };

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            # postCreateHook = "zfs snapshot rtorrent/root@blank";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          persist = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
           # postCreateHook = "zfs snapshot rtorrent/home@blank";
          };
          incus = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
