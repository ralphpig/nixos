# Hyprland + Dux Shell (system side). The shell, Hyprland config and keybinds
# live in ./home.nix and are pulled in here, so importing this one file adds
# a "Hyprland" session to GDM's session menu.
#
# Dux Shell is the whole desktop: bar, launcher, notifications, control center,
# OSD, lock screen, idle/suspend and polkit agent. Nothing else is needed for
# those (no waybar, mako, hyprlock, hypridle, hyprpolkitagent...).
{ pkgs, username, ... }:
{
  home-manager.users.${username}.imports = [ ./home.nix ];

  # Session file for GDM, xdg-desktop-portal-hyprland, polkit, dconf.
  # Not using UWSM: home-manager's hyprland-session.target (./home.nix) is
  # what starts the shell.
  programs.hyprland.enable = true;

  # The Hyprland portal only does screen sharing/screenshots; the GTK one
  # covers file pickers and the rest.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # What the shell's widgets talk to. GNOME already enables these; listed so
  # Hyprland doesn't depend on it.
  services.gnome.gnome-keyring.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;
  services.upower.enable = true;
  services.geoclue2.enable = true; # night light schedule / weather location

  # Electron/Chromium apps (Edge, Spotify, Zed...) run natively on Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
