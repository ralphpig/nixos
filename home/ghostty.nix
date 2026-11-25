# Ghostty, the terminal for every desktop (Super+Return in GNOME and
# Hyprland). Colors and font size come from Stylix. The system-wide terminfo
# lives in modules/packages/apps.nix.
{ lib, ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Stylix sets the regular monospace build; keep the term-spaced one
      # (what GNOME Console used)
      font-family = lib.mkForce "Iosevka Ralphpig Term";

      # Vim-style splits (on top of the defaults: Ctrl-Shift-O/E to split
      # right/down, Ctrl-Shift-Enter to zoom). Ghostty takes these keys
      # before the shell, so zsh's Alt-H (help) / Alt-L (lowercase) are lost.
      keybind = [
        "alt+h=goto_split:left"
        "alt+j=goto_split:down"
        "alt+k=goto_split:up"
        "alt+l=goto_split:right"
        "alt+shift+h=resize_split:left,10"
        "alt+shift+j=resize_split:down,10"
        "alt+shift+k=resize_split:up,10"
        "alt+shift+l=resize_split:right,10"
      ];
    };
  };
}
