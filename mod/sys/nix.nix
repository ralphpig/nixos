# Nix, nixpkgs (unfree, pkgs.unstable) and nh
{ inputs, ... }:
{
  flake.modules.nixos.base = {
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
      enable = true; # `programs.nh.flake` is set by the host
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
