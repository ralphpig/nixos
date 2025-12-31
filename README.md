My NixOS work machine. home-manager config is in my [dotfiles](https://github.com/ralphpig/dotfiles/blob/master/home.nix).

I did not commit:
- `hardware-configuration.nix`
- `luks.nix`

### Example `luks.nix`

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
      device = "/dev/disk/by-...";
      preLVM = true;
    };

    # Better read/write on SSD
    # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
    bypassWorkqueues = true;
    allowDiscards = true;
  };
}
```
