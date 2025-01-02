# Guide
#    https://qfpl.io/posts/installing-nixos/
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./luks.nix
    ./gpu.nix
  ];

  system.autoUpgrade = {
    enable  = true;
    # Don't think I want reboot while I'm in the middle of work
    # I also shutdown and reboot every day
    # allowReboot  = true;
  };
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      # systemd-boot.enable = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };

    initrd.systemd.enable = true;
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

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      # Force plymouth to use simpledrm to avoid 8 second timeout waiting for GPU
      "plymouth.use-simpledrm"
    ];
  };

  networking = {
    hostName = "ralphpig-nixos"; # Define your hostname.

    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # Services
  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    displayManager.sessionCommands = ''
      xset r rate 200 30
    '';

    # Configure keymap in X11
    xkb.layout = "us";
    # xkb.options = "eurosign:e,caps:escape";
  };
  ## Some displayManager conf has been renamed from xserver.displayManager
  services.displayManager = {
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

  # Packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for sublime4
  ];


  environment.systemPackages = with pkgs; [
    home-manager

    # Tools
    bind
    git
    htop
    jq
    neovim
    oh-my-zsh
    ripgrep
    shfmt
    wget
    wl-clipboard
    yamlfmt
    zsh

    # Fonts
    jetbrains-mono

    # Work
    awscli
    deno
    glab
    husky
    insomnia
    nodejs_20
    postgresql
    sublime-merge
    sublime4
    yarn
    zed-editor

    # Applications
    bambu-studio
    bitwarden-cli
    libreoffice
    microsoft-edge
    ## PWAs try to exec `microsoft-edge-stable`, so add an alias for it
    (writeShellScriptBin "microsoft-edge-stable" "exec -a $0 ${microsoft-edge}/bin/microsoft-edge $@")
    spotify
  ];

  # Program Config
  programs.zsh = {
    enable = true;
  };

  virtualisation.docker.enable = true;

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
