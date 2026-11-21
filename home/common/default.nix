# Portable user config, shared by every user (ralphpig and root) and usable
# with standalone home-manager on non-NixOS systems.
{ ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./neovim.nix
  ];

  programs.home-manager.enable = true;
}
