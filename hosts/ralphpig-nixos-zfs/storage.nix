# Hand-maintained disk layout: ZFS root pool (native encryption), ext4 /boot,
# vfat ESP, randomly-encrypted swap. All on one Samsung 980 PRO.
let
  disk = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NU0T801384D";

  zfsMount = dataset: {
    device = "rpool/${dataset}";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };
in
{
  fileSystems = {
    "/" = zfsMount "root";
    "/nix" = zfsMount "nix";
    "/home" = zfsMount "home";
    "/var" = zfsMount "var";
    "/var/log" = zfsMount "var/log";

    "/boot" = {
      device = "${disk}-part2";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "${disk}-part1";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [
    {
      device = "${disk}-part3";
      randomEncryption.enable = true;
      randomEncryption.allowDiscards = true;
    }
  ];

  # ZFS
  networking.hostId = "650a68ba"; # required for zfs; head -c4 /dev/urandom | od -A none -t x4

  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd.supportedFilesystems = [ "zfs" ];

    zfs = {
      requestEncryptionCredentials = true;
      # It is highly recommended to set it to `false`, the new default from 26.11 on, to reduce the risk of data loss.
      forceImportRoot = false;
    };

    kernelParams = [
      "zfs.zfs_arc_max=8589934592" # cap ARC at 8 GiB
      "nohibernate" # cannot hibernate with zfs
    ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true; # NVMe TRIM for the pool
  };
}
