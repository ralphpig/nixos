# Ghostty, the terminal for every desktop. Colors and font size come from Stylix, if used.
{
  flake.modules.nixos.ghostty = { pkgs, ... }: {
    # TERM=xterm-ghostty: install its terminfo system-wide so other users
    # (`su -`, `sudo -i`, root) can find it.
    environment.systemPackages = [ pkgs.ghostty.terminfo ];
  };

  flake.modules.homeManager.ghostty =
    { lib, ... }:
    {
      programs.ghostty = {
        enable = true;
        settings = {
          # Over Stylix's, which is the regular monospace build; keep the term-spaced one
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
    };
}
