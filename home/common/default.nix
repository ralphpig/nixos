# Portable user config, shared by every user (ralphpig and root) and usable
# with standalone home-manager on non-NixOS systems.
{ config, lib, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./neovim.nix
  ];

  options.my.repoDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nixos";
    description = ''
      Absolute path of this repo's checkout. Used for live (out-of-store)
      references such as ~/.config symlinks and the wallpaper.
    '';
  };

  config.programs.home-manager.enable = true;
}
