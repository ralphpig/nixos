# Same shell/git/editor setup as the main user.
{ ... }:
{
  imports = [ ./common ];

  # Don't change: see `home.stateVersion` in the home-manager manual.
  home.stateVersion = "26.05";
}
