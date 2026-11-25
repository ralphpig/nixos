# Insomnia (API client)
{
  flake.modules.homeManager.insomnia = { pkgs, ... }: {
    home.packages = with pkgs; [
      insomnia
      # Insomnia ships its icon loose in share/icons/ rather than in an icon
      # theme; GNOME finds it there, Qt apps (the Hyprland shell's dock and
      # launcher) don't. Put a copy in hicolor.
      (runCommand "insomnia-icon" { } ''
        install -Dm644 ${insomnia}/share/icons/insomnia.png \
          $out/share/icons/hicolor/512x512/apps/insomnia.png
      '')
    ];
  };
}
