{
  config,
  lib,
  pkgs,
  ...
}: {
  # LUKS Encryption
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/cb0fa65e-e283-47f9-8db0-908ddad28199";
      preLVM = true;
    };
  };
}
