# Guide
#    https://qfpl.io/posts/installing-nixos/
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  ...
}:
let
  # Bring in nixpkgs-unstable alongside your stable pkgs
  unstable = import <nixpkgs-unstable> {
    config = config.nixpkgs.config;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./luks.nix
    ./gpu.nix
  ];

  system.autoUpgrade = {
    # Everything lags on first startup while this is working (I think)
    enable = false;
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
        configurationLimit = 10;
        extraConfig = ''
          # Wait for selection
          set timeout=-1
        '';
        fontSize = 24;
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

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      # Enable "Silent Boot"
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
    hostName = "ralphpig-nixos";

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
  };

  # Services
  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment.

    displayManager.sessionCommands = ''
      xset r rate 200 30
    '';

    # Configure keymap in X11
    xkb.layout = "us";
    # xkb.options = "eurosign:e,caps:escape";
  };

  services.desktopManager = {
    gnome.enable = true;
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

  # Packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for sublime4
  ];

  environment.systemPackages = with pkgs; [
    home-manager

    # Code
    deno
    eslint
    jre
    nodejs_22
    sublime-merge
    sublime4
    unstable.codex
    unstable.codex-acp
    unstable.zed-editor
    yarn

    # Tools
    bind
    git
    htop
    jq
    ncdu
    neovim
    nil
    nixd
    oh-my-zsh
    ripgrep
    shfmt
    sql-formatter
    wget
    wl-clipboard
    yamlfmt
    zsh

    # Work
    awscli2
    glab
    husky
    insomnia
    kubectl
    kubeseal
    mongodb-compass
    mongodb-tools
    postgresql

    # Applications
    bambu-studio
    bitwarden-cli
    gnome-tweaks
    libreoffice
    microsoft-edge
    ## PWAs try to exec `microsoft-edge-stable`, so add an alias for it
    (writeShellScriptBin "microsoft-edge-stable" "exec -a $0 ${microsoft-edge}/bin/microsoft-edge $@")
    spotify
    zoom-us
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      lilex
      # No real customization, just couldn't get the bundle of weights/styles I wanted
      (iosevka.override {
        set = "Ralphpig";
        privateBuildPlan = ''
          [buildPlans.IosevkaRalphpig]
          family = "Iosevka Ralphpig"
          spacing = "normal"
          serifs = "sans"
          noCvSs = true
          exportGlyphNames = false

          [buildPlans.IosevkaRalphpig.weights.Regular]
          shape = 400
          menu = 400
          css = 400

          [buildPlans.IosevkaRalphpig.weights.Bold]
          shape = 700
          menu = 700
          css = 700

          [buildPlans.IosevkaRalphpig.widths.Normal]
          shape = 600
          menu = 5
          css = "normal"

          [buildPlans.IosevkaRalphpig.slopes.Upright]
          angle = 0
          shape = "upright"
          menu = "upright"
          css = "normal"

          [buildPlans.IosevkaRalphpig.slopes.Italic]
          angle = 9.4
          shape = "italic"
          menu = "italic"
          css = "italic"
        '';
      })
      (iosevka.override {
        set = "RalphpigTerm";
        privateBuildPlan = ''
          [buildPlans.IosevkaRalphpigTerm]
          family = "Iosevka Ralphpig Term"
          spacing = "term"
          serifs = "sans"
          noCvSs = true
          exportGlyphNames = false

          [buildPlans.IosevkaRalphpigTerm.weights.Regular]
          shape = 400
          menu = 400
          css = 400

          [buildPlans.IosevkaRalphpigTerm.weights.Bold]
          shape = 700
          menu = 700
          css = 700

          [buildPlans.IosevkaRalphpigTerm.widths.Normal]
          shape = 600
          menu = 5
          css = "normal"

          [buildPlans.IosevkaRalphpigTerm.slopes.Upright]
          angle = 0
          shape = "upright"
          menu = "upright"
          css = "normal"

          [buildPlans.IosevkaRalphpigTerm.slopes.Italic]
          angle = 9.4
          shape = "italic"
          menu = "italic"
          css = "italic"
        '';
      })
      (iosevka.override {
        set = "RalphpigProportional";
        privateBuildPlan = ''
          [buildPlans.IosevkaRalphpigProportional]
          family = "Iosevka Ralphpig Proportional"
          spacing = "quasi-proportional"
          serifs = "sans"
          noCvSs = true
          exportGlyphNames = false

          [buildPlans.IosevkaRalphpigProportional.weights.Regular]
          shape = 400
          menu = 400
          css = 400

          [buildPlans.IosevkaRalphpigProportional.weights.Bold]
          shape = 700
          menu = 700
          css = 700

          [buildPlans.IosevkaRalphpigProportional.widths.Normal]
          shape = 600
          menu = 5
          css = "normal"

          [buildPlans.IosevkaRalphpigProportional.slopes.Upright]
          angle = 0
          shape = "upright"
          menu = "upright"
          css = "normal"

          [buildPlans.IosevkaRalphpigProportional.slopes.Italic]
          angle = 9.4
          shape = "italic"
          menu = "italic"
          css = "italic"
        '';
      })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Iosevka Ralphpig Proportional" ];
        sansSerif = [ "Iosevka Ralphpig Proportional" ];
        monospace = [ "Iosevka Ralphpig" ];
      };
    };
  };

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

  # Don't change ever
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Don't change ever
}
