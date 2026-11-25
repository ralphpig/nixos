{ ... }:
{
  imports = [
    ./common
    ./dotfiles.nix
    ./ghostty.nix
  ];

  # Desktop-specific config (e.g. ../desktop/gnome/home.nix) is imported by the
  # desktop's NixOS module, so it follows whichever desktop the host enables.

  # Don't change: see `home.stateVersion` in the home-manager manual.
  home.stateVersion = "24.05";
}
