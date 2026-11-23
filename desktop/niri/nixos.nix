# niri + Dux Shell (system side). niri's config and keybinds live in
# ./home.nix, the shell in ../dux-shell; both are pulled in here, so importing
# this one file adds a "Niri" session to GDM's session menu.
{ pkgs, username, ... }:
{
  imports = [ ../dux-shell/nixos.nix ];

  home-manager.users.${username}.imports = [ ./home.nix ];

  # Session file for GDM (niri-session, which runs niri.service; that starts
  # the shell, see ./home.nix), xdg-desktop-portal-gnome for screen sharing,
  # gnome-keyring, polkit, dconf.
  programs.niri.enable = true;

  # X11 apps (Steam, some games, older Electron): niri starts it on demand
  # when it's on PATH
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
