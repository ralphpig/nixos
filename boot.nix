{
  pkgs,
  ...
}:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 10;
        extraConfig = ''
          # Wait for selection
          set timeout=-1
        '';

        gfxmodeEfi = "1920x1080";
        fontSize = 24;
      };
    };

    plymouth = {
      enable = true;
      theme = "square";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "square" ];
        })
      ];
    };

    initrd = {
      verbose = false;
      systemd.enable = true;

      # usbhid is in hardware-configuration.nix's availableKernelModules, so it is
      # only loaded once udev matches a device. Load it unconditionally at stage 1
      # start instead, to shave what little can be shaved off the window between
      # plymouth taking the password prompt and the keyboard existing.
      kernelModules = [
        "usbhid"
        "hid_generic"
      ];
    };

    # ZFS
    supportedFilesystems = [ "zfs" ];
    initrd.supportedFilesystems = [ "zfs" ];
    zfs = {
      requestEncryptionCredentials = true;
      # It is highly recommended to set it to `false`, the new default from 26.11 on, to reduce the risk of data loss.
      forceImportRoot = false;
    };

    consoleLogLevel = 0;

    kernelParams = [
      # Enable "Silent Boot"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"

      # ZFS
      "zfs.zfs_arc_max=8589934592" # cap ARC at 8 GiB
      "nohibernate" # cannot hibernate with zfs

      # Keep stage 1 on simpledrm rather than waiting on / modesetting the real
      # GPU. Paired with hardware.amdgpu.initrd.enable staying off in gpu.nix.
      "plymouth.use-simpledrm"
    ];
  };

  networking.hostId = "650a68ba"; # required for zfs; head -c4 /dev/urandom | od -A none -t x4
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true; # NVMe TRIM for the pool
  };
}
