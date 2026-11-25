# Only what every user gets (homeManager.base: zsh, git, neovim...).
{
  # Don't change: see `home.stateVersion` in the home-manager manual.
  flake.modules.nixos.user-root.home-manager.users.root.home.stateVersion = "26.05";
}
