# Dux Shell (system side), shared by the compositors that run it. Imported by
# each compositor's nixos.nix (../hyprland, ../niri); importing it twice is
# fine, NixOS loads a file once.
#
# Dux Shell is the whole desktop: bar, launcher, notifications, control center,
# OSD, lock screen, idle/suspend and polkit agent. Nothing else is needed for
# those (no waybar, mako, swaylock, hypridle, polkit agents...).
{ pkgs, username, ... }:
{
  home-manager.users.${username}.imports = [ ./home.nix ];

  # The compositors' portals only do screen sharing/screenshots; the GTK one
  # covers file pickers and the rest.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # What the shell's widgets talk to. GNOME already enables these; listed so
  # the shell doesn't depend on it.
  services.gnome.gnome-keyring.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;
  services.upower.enable = true;
  services.geoclue2.enable = true; # night light schedule / weather location

  # The shell's network UI only connects/disconnects. For editing connections
  # (VPN import, split tunnel, credentials): nm-connection-editor ("Advanced
  # Network Configuration" in the launcher), or GNOME's `gnome-control-center network`.
  environment.systemPackages = [ pkgs.networkmanagerapplet ];

  # Electron/Chromium apps (Edge, Spotify, Zed...) run natively on Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
