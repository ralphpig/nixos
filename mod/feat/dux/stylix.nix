# Dux Shell's theme, fonts and wallpaper from Stylix, when the host has it.
{
  flake.modules.homeManager.dux =
    {
      config,
      lib,
      options,
      ...
    }:
    let
      inherit (config.lib.stylix) colors;

      # Stylix palette as a Dux Shell custom theme. Stylix's own
      # dank-material-shell target is disabled below because it writes
      # settings.json into the store and makes the shell's Settings read-only.
      # It also maps the panel (surface) to base01, the same color as the cards
      # on it; here each layer is one base16 step lighter, like the built-in
      # themes. Used for light mode too (the shell falls back to `dark`).
      theme = with colors.withHashtag; {
        name = "Stylix";
        primary = base0D;
        primaryText = base00;
        secondary = base0E;
        surface = base00; # panels
        surfaceText = base05;
        surfaceVariant = base02;
        surfaceVariantText = base04;
        surfaceTint = base0D;
        background = base00;
        backgroundText = base05;
        outline = base03;
        surfaceContainer = base01; # cards
        surfaceContainerHigh = base02; # buttons, chips
        surfaceContainerHighest = base03; # chips on chips
        error = base08;
        warning = base0A;
        info = base0C;
      };
      # Not in ~/.config/dms: that's a symlink into the repo
      themeFile = "${config.xdg.dataHome}/dms/stylix-theme.json";
    in
    {
      config = lib.optionalAttrs (options ? stylix) {
        my.dux.settings = {
          currentThemeName = "custom";
          currentThemeCategory = "custom"; # the Settings theme page's tab
          customThemeFile = themeFile;
          fontFamily = config.stylix.fonts.sansSerif.name;
          monoFontFamily = config.stylix.fonts.monospace.name;
        };

        my.dux.session = {
          wallpaperPath = config.stylix.image;
          wallpaperPathLight = config.stylix.image;
          wallpaperPathDark = config.stylix.image;
        };

        # Wallpaper-based colors (matugen). Off: Stylix sets the colors for the
        # shell (theme file above) and for GTK/Qt apps.
        programs.dank-material-shell.enableDynamicTheming = false;

        stylix.targets.dank-material-shell.enable = false; # replaced by the theme file above

        xdg.dataFile."dms/stylix-theme.json".text = builtins.toJSON { dark = theme; };

        # The shell doesn't notice when a rebuild relinks its theme file, so
        # restart it whenever the theme changes
        systemd.user.services.dms.Unit.X-Restart-Triggers = [
          config.xdg.dataFile."dms/stylix-theme.json".source
        ];

      };
    };
}
