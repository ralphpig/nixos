# Bootloader and splash. ZFS boot bits live in ./storage.nix.
{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.elegant-grub2-themes.nixosModules.default ];

  # Sets boot.loader.grub.{theme,splashImage,gfxmode*}
  boot.loader.elegant-grub2-theme = {
    enable = true;
    theme = "wave";
    type = "window";
    side = "left";
    color = "dark";
    screen = "1080p";
  };

  boot = {
    loader = {
      efi.efiSysMountPoint = "/boot/efi";
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

        # gfxmodeEfi is set by the Elegant theme module above
        fontSize = 24;
      };
    };

    plymouth = {
      enable = true;
      theme = "hexagon_2";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "hexagon_2" ];
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
      # kernelModules = [
      #  "usbhid"
      #  "hid_generic"
      # ];
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

      # Keep stage 1 on simpledrm rather than waiting on / modesetting the real
      # GPU (i.e. leave hardware.amdgpu.initrd.enable off).
      "plymouth.use-simpledrm"
    ];
  };
}
