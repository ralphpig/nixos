# GNOME on GDM (system side). User-level GNOME settings (dconf, extensions,
# keybinds) will live next to this in ./home.nix.
{ pkgs, username, ... }:
{
  services.xserver = {
    enable = true;

    # X11 only; GNOME (Wayland) takes repeat rate from dconf instead
    displayManager.sessionCommands = ''
      xset r rate 200 30
    '';

    xkb.layout = "us";
    # xkb.options = "eurosign:e,caps:escape";
  };

  services.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.mutter]
      experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
    '';
  };

  services.displayManager = {
    gdm.enable = true;

    autoLogin.enable = true;
    autoLogin.user = username;
  };

  # Autologin Workaround: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
}
