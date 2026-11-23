# Hyprland + Dux Shell (home-manager side). Imported by ./nixos.nix.
#
# Who owns what:
# - Nix: ~/.config/hypr/hyprland.lua (base config, below, plus keybinds from
#   ./binds.nix), the shell's package and service, and the Stylix theme file.
# - Dotfiles in ./config, symlinked live like home/dotfiles.nix (the shell's
#   Settings app edits them; changes show up in `git diff`, no rebuild):
#     ./config/dms      -> ~/.config/dms       (settings.json)
#     ./config/hypr-dms -> ~/.config/hypr/dms  (monitors, input, layout,
#                                               window rules, binds-user)
#   Whole directories are linked because the shell saves by writing a temp
#   file and renaming it over the old one, which would replace a per-file
#   symlink with a plain file.
# - Both: settings that come from Stylix (theme, fonts) are merged into
#   settings.json on every rebuild, overriding what the UI set for those keys.
#   All settings keys and their defaults: quickshell/Common/settings/
#   SettingsSpec.js in the shell's source (or change one in the UI and look
#   at `git diff`).
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

  # Fragments the shell writes into ~/.config/hypr/dms/, in its stock order.
  # Not its binds.lua: keybinds are in ./binds.nix.
  dmsFragments = [
    "colors"
    "outputs"
    "layout"
    "cursor"
    "input"
    "binds-user"
    "windowrules"
  ];
in
{
  imports = [
    inputs.dms.homeModules.default
    ./binds.nix
  ];

  programs.dank-material-shell = {
    enable = true;
    # Fix: clicking a bar widget again without moving the mouse reopened its
    # popout instead of closing it. While a popout is open, Hyprland only
    # delivers clicks to an allow-list of the shell's surfaces; the bar was
    # only on it once the popout had keyboard focus, which with
    # focus-follows-mouse needs pointer motion. So the click counted as
    # "outside" (closing the popout) and also reached the bar (reopening it).
    # Keep the bar on the list. Fails to build if upstream changes the line;
    # then check whether it's fixed there and drop this.
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell.overrideAttrs (old: {
      postInstall = old.postInstall + ''
        substituteInPlace $out/share/quickshell/dms/Widgets/DPopout.qml --replace-fail \
          'return list.concat(transientWindows);' \
          'return list.concat(transientWindows).concat(KeyboardFocus.barWindows);'
      '';
    });
    systemd = {
      enable = true;
      # Default is graphical-session.target, which GNOME reaches too
      target = "hyprland-session.target";
    };
    # Wallpaper-based colors (matugen). Off: Stylix sets the colors for the
    # shell (theme file above) and for GTK/Qt apps.
    enableDynamicTheming = false;
  };

  stylix.targets = {
    dank-material-shell.enable = false; # replaced by the theme file above
    hyprland.hyprpaper.enable = false; # the shell draws the wallpaper
  };

  xdg.dataFile."dms/stylix-theme.json".text = builtins.toJSON { dark = theme; };

  xdg.configFile =
    let
      link =
        path: config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/desktop/hyprland/config/${path}";
    in
    {
      "dms".source = link "dms";
      "hypr/dms".source = link "hypr-dms";
    };

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

  wayland.windowManager.hyprland = {
    enable = true;
    # Use the NixOS module's Hyprland and portal (./nixos.nix)
    package = null;
    portalPackage = null;
    # Dux Shell 2.x only speaks Hyprland's Lua config
    configType = "lua";
    # Starts hyprland-session.target, which starts the shell (systemd.enable
    # is on by default)

    settings.config = {
      input = {
        kb_layout = "us";
        # Same feel as GNOME (200ms delay, 30ms interval)
        repeat_delay = 200;
        repeat_rate = 33;
        follow_mouse = 1; # sloppy focus
      };
      general.layout = "dwindle";
      dwindle.preserve_split = true;
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
    };

    # Compositor animations: windows opening/closing/moving, workspace
    # switches. The shell's animation setting only covers its own popouts.
    # speed is in 100ms units, lower is faster. Leaves (windowsIn, fadeOut...)
    # not listed inherit from their parent. All leaves:
    # https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
    #
    # Curves: cubic beziers, two control points as [ time progress ]. Define
    # as many as you like and pick one per animation with `bezier` below.
    # Compare shapes at https://cubic-bezier.com and https://easings.net
    settings.curve =
      lib.mapAttrsToList
        (name: points: {
          _args = [
            name
            {
              type = "bezier";
              inherit points;
            }
          ];
        })
        {
          # Custom: nearly all the motion in the first ~15%, then a long
          # invisible settle, so it feels faster than its speed says
          snappy = [
            [
              0.05
              0.9
            ]
            [
              0.1
              1.0
            ]
          ];
          # Standard ease-out (easings.net); Hyprland's stock config uses it
          # for borders and layers. Softer than snappy at the same speed.
          easeOutQuint = [
            [
              0.23
              1
            ]
            [
              0.32
              1
            ]
          ];
        };
    settings.animation =
      map
        (
          a:
          {
            enabled = true;
            bezier = "easeOutQuint"; # or "snappy"
          }
          // a
        )
        [
          {
            leaf = "global";
            speed = 3;
          }
          {
            leaf = "windowsIn";
            speed = 3;
            style = "popin 80%";
          }
          {
            leaf = "windowsOut";
            speed = 2;
            style = "popin 80%";
          }
          {
            leaf = "windowsMove";
            speed = 3;
          }
          {
            leaf = "workspaces";
            speed = 3;
            style = "slide";
          }
        ];
    # # The shell animates its own panels (dashboard, quick settings, launcher,
    # # bar...); Hyprland animating the same surfaces on top fights with it.
    # # Same rules as the shell's stock hyprland.lua.
    # settings.layer_rule =
    #   map
    #     (namespace: {
    #       match.namespace = namespace;
    #       no_anim = true;
    #     })
    #     [
    #       "^(quickshell)$"
    #       "^dms:.*"
    #     ];

    # The shell's fragments (./config/hypr-dms). A missing one is skipped
    # (colors and cursor don't exist until set in the shell's Settings); an
    # error inside one still surfaces.
    extraConfig = ''
      for _, name in ipairs({ ${lib.concatMapStringsSep ", " (f: ''"${f}"'') dmsFragments} }) do
        local ok, err = pcall(require, "dms." .. name)
        if not ok and not tostring(err):find("module 'dms%." .. name:gsub("%-", "%%-") .. "' not found") then
          error(err)
        end
      end
    '';
  };
}
