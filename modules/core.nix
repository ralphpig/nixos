# Baseline for any machine: nix/nixpkgs settings, locale, networking, the user.
{
  config,
  inputs,
  pkgs,
  username,
  ...
}:
{
  nix.settings = {
    download-buffer-size = 524288000; # 500 MiB
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;

    # Expose nixpkgs-unstable as `pkgs.unstable`
    overlays = [
      (final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (final) config;
        };
      })
    ];
  };

  system.autoUpgrade = {
    # Everything lags on first startup while this is working (I think)
    enable = false;
    # Don't think I want reboot while I'm in the middle of work
    # I also shutdown and reboot every day
    # allowReboot  = true;
  };

  programs.nh = {
    enable = true;
    flake = "${config.users.users.${username}.home}/nixos";
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  time.timeZone = "America/New_York";

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  hardware.graphics.enable = true;

  # Users
  programs.zsh.enable = true; # registers zsh as a login shell
  users = {
    defaultUserShell = pkgs.zsh;

    users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };
}
