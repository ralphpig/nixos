# Bootloader (grub, UEFI) and splash, shared by hosts but not part of `base`:
# hosts import `boot`, and can override what's mkDefault by just setting it
# (the rest needs lib.mkForce). The ESP's mount point is the host's.
{ inputs, ... }:
{
  flake.modules.nixos.boot =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.elegant-grub2-themes.nixosModules.default ];

      boot = {
        loader = {
          timeout = lib.mkDefault null; # wait for selection
          efi.canTouchEfiVariables = lib.mkDefault true;

          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            configurationLimit = lib.mkDefault 10;

            # gfxmodeEfi is set by the Elegant theme module above
            fontSize = lib.mkDefault 24;
          };

          # Sets boot.loader.grub.{theme,splashImage,gfxmode*}
          elegant-grub2-theme = {
            enable = true;
            theme = lib.mkDefault "wave";
            type = lib.mkDefault "window";
            side = lib.mkDefault "left";
            color = lib.mkDefault "dark";
            screen = lib.mkDefault "1080p";
          };
        };

        plymouth = {
          enable = lib.mkDefault true;
          theme = lib.mkDefault "hexagon_2";
          themePackages = with pkgs; [
            # By default we would install all themes
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "hexagon_2" ];
            })
          ];
        };

        initrd = {
          verbose = lib.mkDefault false;
          systemd.enable = true;

          # usbhid is in _hardware-configuration.nix's availableKernelModules, so it is
          # only loaded once udev matches a device. Load it unconditionally at stage 1
          # start instead, to shave what little can be shaved off the window between
          # plymouth taking the password prompt and the keyboard existing.
          # kernelModules = [
          #  "usbhid"
          #  "hid_generic"
          # ];
        };

        consoleLogLevel = lib.mkDefault 0;

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
    };
}
