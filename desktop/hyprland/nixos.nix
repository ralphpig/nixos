# Hyprland + Dux Shell (system side). Hyprland's config and keybinds live in
# ./home.nix, the shell in ../dux-shell; both are pulled in here, so importing
# this one file adds a "Hyprland" session to GDM's session menu.
{ username, ... }:
{
  imports = [ ../dux-shell/nixos.nix ];

  home-manager.users.${username}.imports = [ ./home.nix ];

  # Session file for GDM, xdg-desktop-portal-hyprland, polkit, dconf.
  # Not using UWSM: home-manager's hyprland-session.target (./home.nix) is
  # what starts the shell.
  programs.hyprland.enable = true;
}
