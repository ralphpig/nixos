# Dux Shell (home-manager side), shared by the compositors that run it.
# Imported by ./nixos.nix.
#
# Who owns what:
# - Nix: the shell's package and service, and the Stylix theme file.
#   Compositor-specific parts (its config, keybinds, the shell's fragments for
#   it) live with the compositor (../hyprland, ../niri).
# - Dotfiles in ./config, symlinked live like home/dotfiles.nix (the shell's
#   Settings app edits them; changes show up in `git diff`, no rebuild):
#     ./config/dms -> ~/.config/dms (settings.json, one for every compositor)
#   The whole directory is linked because the shell saves by writing a temp
#   file and renaming it over the old one, which would replace a per-file
#   symlink with a plain file.
# - Both: settings that come from Stylix (theme, fonts) are merged into
#   settings.json on every rebuild, overriding what the UI set for those keys.
#   All settings keys and their defaults: quickshell/Common/settings/
#   SettingsSpec.js in the shell's source (or change one in the UI and look
#   at `git diff`).
#
# Starting it: the service is wanted by dux-shell.target, which each
# compositor pulls into its own session (not graphical-session.target, which
# GNOME reaches too).
{
  config,
  lib,
  pkgs,
  inputs,
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

  # Merged into settings.json on every rebuild (Nix wins for these keys)
  stylixSettings = pkgs.writeText "dms-stylix-settings.json" (
    builtins.toJSON {
      currentThemeName = "custom";
      currentThemeCategory = "custom"; # the Settings theme page's tab
      customThemeFile = themeFile;
      fontFamily = config.stylix.fonts.sansSerif.name;
      monoFontFamily = config.stylix.fonts.monospace.name;
    }
  );

  # Merged into session.json (runtime state, not tracked) on every rebuild.
  # Nix wins over what was picked in the shell for these keys.
  nixSession = pkgs.writeText "dms-session.json" (
    builtins.toJSON {
      # Follows stylix.image
      wallpaperPath = config.stylix.image;
      wallpaperPathLight = config.stylix.image;
      wallpaperPathDark = config.stylix.image;
      # The dock's pinned apps, same as GNOME's dash. Keyed by the dock's id
      # in settings.json (dockConfigs); pins are desktop file names without
      # .desktop.
      dockPins.dock = map (lib.removeSuffix ".desktop") (import ../favorite-apps.nix);
    }
  );
in
{
  imports = [ inputs.dms.homeModules.default ];

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      target = "dux-shell.target";
    };
    # Wallpaper-based colors (matugen). Off: Stylix sets the colors for the
    # shell (theme file above) and for GTK/Qt apps.
    enableDynamicTheming = false;
  };

  # Started by the compositors' sessions: each adds its session unit to
  # Install.WantedBy. Stops with the graphical session on logout.
  systemd.user.targets.dux-shell.Unit = {
    Description = "Dux Shell session";
    PartOf = [ "graphical-session.target" ];
    After = [ "graphical-session.target" ];
  };

  stylix.targets.dank-material-shell.enable = false; # replaced by the theme file above

  xdg.dataFile."dms/stylix-theme.json".text = builtins.toJSON { dark = theme; };

  xdg.configFile."dms".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/desktop/dux-shell/config/dms";

  # Merge Nix-owned keys into files the shell also writes. In place (keeps
  # the repo symlink), only on change (clean git diff), and formatted like the
  # shell writes them (2-space indent, no trailing newline).
  home.activation.duxShellSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    merge() {
      local file=$1 keys=$2 merged
      if [ -e "$file" ]; then
        merged=$(${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$file" "$keys")
      else
        merged=$(${lib.getExe pkgs.jq} . "$keys")
        run mkdir -p "$(dirname "$file")"
      fi
      if [ "$merged" != "$(cat "$file" 2>/dev/null)" ]; then
        run eval 'printf "%s" "$merged" > "$file"'
      fi
    }
    merge "${config.xdg.configHome}/dms/settings.json" ${stylixSettings}
    merge "${config.xdg.stateHome}/dms/session.json" ${nixSession}
  '';

  # The shell doesn't notice when a rebuild relinks its theme file, so
  # restart it whenever the theme changes
  systemd.user.services.dms.Unit.X-Restart-Triggers = [
    config.xdg.dataFile."dms/stylix-theme.json".source
  ];
}
