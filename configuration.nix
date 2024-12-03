# Guide
#    https://qfpl.io/posts/installing-nixos/

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
{
  imports = [
	# Include the results of the hardware scan.
  	./hardware-configuration.nix
  ];

  boot = {
  	# Use the systemd-boot EFI boot loader.
  	loader.systemd-boot.enable = true;
  	loader.efi.canTouchEfiVariables = true;
	
  	# LUKS Encryption
  	initrd.luks.devices = {
    		root = { 
      			device = "/dev/disk/by-uuid/cb0fa65e-e283-47f9-8db0-908ddad28199";
      			preLVM = true;
    		};
  	};
  };

  networking = {
  	hostName = "ralphpig-nixos"; # Define your hostname.

  	networkmanager.enable = true;  # Easiest to use and most distros use this by default.
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
	XDG_CACHE_HOME  = "$HOME/.cache";
	XDG_CONFIG_HOME = "$HOME/.config";
	XDG_DATA_HOME   = "$HOME/.local/share";
	XDG_STATE_HOME  = "$HOME/.local/state";
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

  services.printing.enable = true;

  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ZSH
  programs.zsh.enable = true;
  
  users = {
  	defaultUserShell = pkgs.zsh;

  	users.ralphpig = {
    		isNormalUser = true;
    		extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    		# packages = with pkgs; [];
  	};
  };


  # Packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for sublime4
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    # Tools
    vim 
    wget
    git
    htop
    zsh
    jq
    ripgrep
    bind
    nodejs_20
    yarn
    docker
    oh-my-zsh
    yamlfmt

    # Fonts
    jetbrains-mono
    
    # Applications
    microsoft-edge
    zed-editor
    sublime4
    sublime-merge
    pritunl-client
    bambu-studio
    bitwarden-cli
    glab
    insomnia
    spotify
    bambu-studio
    libreoffice
  ];

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

