# Guide
#    https://qfpl.io/posts/installing-nixos/
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./boot.nix
    ./applications.nix
  ];

  nix.settings.download-buffer-size = 524288000; # 500 MiB
  system.autoUpgrade = {
    # Everything lags on first startup while this is working (I think)
    enable = false;
    # Don't think I want reboot while I'm in the middle of work
    # I also shutdown and reboot every day
    # allowReboot  = true;
  };

  hardware.graphics = {
    enable = true;
  };

  networking = {
    hostName = "ralphpig-nixos-zfs";

    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  time = {
    timeZone = "America/New_York";

    # Windows expect local time
    hardwareClockInLocalTime = true;
  };

  # Select internationalisation properties.
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Allow rustc to find openssl
    PKG_CONFIG_PATH = [ "${pkgs.openssl.dev}/lib/pkgconfig" ];
  };

  # Services
  virtualisation.docker.enable = true;

  services.xserver = {
    enable = true;

    displayManager.sessionCommands = ''
      xset r rate 200 30
    '';

    # Configure keymap in X11
    xkb.layout = "us";
    # xkb.options = "eurosign:e,caps:escape";
  };

  services.desktopManager = {
    gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
      '';
    };
  };

  services.displayManager = {
    gdm.enable = true;

    # Autologin
    autoLogin.enable = true;
    autoLogin.user = "ralphpig";
  };

  # Autologin Workaround: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Printing
  services.printing.enable = true;
  # IPP Everywhere auto-discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Users
  users = {
    defaultUserShell = pkgs.zsh;

    users.ralphpig = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };

  # Don't change ever
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Don't change ever
}
