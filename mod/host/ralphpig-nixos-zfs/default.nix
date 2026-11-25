# Desktop workstation: Intel CPU, AMD RX 9070 XT, ZFS on a single NVMe.
{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.nixosConfigurations.ralphpig-nixos-zfs = inputs.nixpkgs.lib.nixosSystem {
    modules = with nixos; [
      base # mod/sys, except the optional boot
      boot

      user-ralphpig
      user-root

      # The system half of features. Their home half, and features with only
      # that, are picked per user in mod/user.
      #
      # All desktops are installed; switch by logging out and picking one from
      # GDM's session menu (gear icon). GDM itself lives in gnome.
      dux
      gnome
      hyprland
      niri

      docker
      ghostty
      spotifast
      stylix
      sublime

      # ollama

      ./_hardware-configuration.nix
      ./_storage.nix

      {
        networking.hostName = "ralphpig-nixos-zfs";

        programs.nh.flake = "/home/ralphpig/nixos";

        services.displayManager = {
          autoLogin.enable = true;
          autoLogin.user = "ralphpig";

          # Session GDM autologins into at boot ("gnome", "hyprland" or
          # "niri"). Set to null to autologin into whichever session was used
          # last instead.
          defaultSession = "niri";
        };

        # Autologin Workaround: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
        systemd.services."getty@tty1".enable = false;
        systemd.services."autovt@tty1".enable = false;

        # Dual boot with Windows, which expects local time
        boot.loader.grub.useOSProber = true;
        time.hardwareClockInLocalTime = true;

        # Don't change ever
        # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
        system.stateVersion = "24.11";
      }
    ];
  };
}
