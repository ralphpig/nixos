# luks.nix

```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # LUKS Encryption
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/<uuid>";
      preLVM = true;
    };
  };
}
```
