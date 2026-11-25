# niri (home-manager side). Imported by ./nixos.nix. The shell itself
# (package, service, theme, settings.json) is ../dux-shell.
#
# Who owns what:
# - Nix: ~/.config/niri/config.kdl (base config, below) and binds.kdl
#   (./binds.nix). Checked with `niri validate` at build time, so a broken
#   config fails the rebuild instead of the session. niri reloads them live.
# - Dotfiles in ./config, symlinked live like home/dotfiles.nix (the shell's
#   Settings app edits them; changes show up in `git diff`, no rebuild):
#     ./config/niri-dms -> ~/.config/niri/dms  (monitors, input, layout,
#                                               window rules, binds, cursor)
#   The whole directory is linked; ../dux-shell/home.nix says why.
#   Included after the base config, so what's set there wins (including
#   binds made in the shell's keybinds editor, which go to dms/binds.kdl).
#
# Full config reference: https://yalter.github.io/niri/Configuration:-Introduction
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) cursor;

  # Fragments the shell writes into ~/.config/niri/dms/, in its stock order.
  # Missing ones are skipped (most don't exist until set in Settings).
  dmsFragments = [
    "colors"
    "layout"
    "alttab"
    "binds"
    "outputs"
    "cursor"
    "input"
    "windowrules"
    "wpblur"
  ];

  # Fixed workspaces "1"-"10", always there even when empty (like GNOME's
  # static workspaces); more appear below them as needed. Super+1-0 go to
  # them by name (./binds.nix), so moving one in the overview doesn't
  # change its key.
  workspaces = map toString (lib.range 1 10);

  # Apps with a home workspace: started at login, and their windows open
  # there at full width (like Super+F). `startupOnly`: only windows opened in
  # niri's first minute (so a terminal or browser window opened later stays
  # where you are, at the default width).
  # None of them take focus in that first minute, so login stays on workspace
  # 1, where the keyring prompt opens.
  # `background`: never take focus on opening. Find app ids with
  # `niri msg windows` or `niri msg pick-window`.
  workspaceApps = [
    {
      workspace = "1";
      appId = ''^dev\.zed\.Zed$'';
      command = "zeditor";
    }
    {
      workspace = "2";
      appId = ''^com\.mitchellh\.ghostty$'';
      command = "ghostty";
      startupOnly = true;
    }
    {
      workspace = "3";
      appId = "^sublime_merge$";
      command = "sublime_merge";
    }
    {
      workspace = "4";
      appId = "^microsoft-edge$"; # not its PWAs (msedge-<id>-Default)
      command = "microsoft-edge";
      startupOnly = true;
    }
    {
      # Teams PWA: the id is per install, see ../favorite-apps.nix
      workspace = "5";
      appId = "^msedge-ompifgpmddkgmclendfeacglnodjjndh-Default$";
      command = "microsoft-edge --profile-directory=Default --app-id=ompifgpmddkgmclendfeacglnodjjndh";
      background = true;
    }
    {
      workspace = "10";
      appId = "^spotify$";
      command = "spotify";
      background = true;
    }
  ];

  workspaceKdl = lib.concatMapStrings (w: ''
    workspace "${w}"
  '') workspaces;

  workspaceAppsKdl = lib.concatMapStrings (
    {
      workspace,
      appId,
      command,
      startupOnly ? false,
      background ? false,
    }:
    ''
      spawn-sh-at-startup ${builtins.toJSON command}
      window-rule {
          match app-id=r#"${appId}"#${lib.optionalString startupOnly " at-startup=true"}
          open-on-workspace "${workspace}"
          open-maximized true${lib.optionalString background "\n    open-focused false"}
      }
      window-rule {
          match app-id=r#"${appId}"# at-startup=true
          open-focused false
      }
    ''
  ) workspaceApps;

  configKdl = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
            // Same feel as GNOME (200ms delay, 30ms interval)
            repeat-delay 200
            repeat-rate 33
        }
        // Sloppy focus, but don't scroll the strip to a window the pointer
        // only grazes
        focus-follows-mouse max-scroll-amount="0%"
    }

    layout {
        // The shell draws the wallpaper (also behind the overview)
        background-color "transparent"
        center-focused-column "never"
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }
        default-column-width { proportion 0.5; }
        // Widths come from the shell's layout.kdl; colors from Stylix
        focus-ring {
            active-color "${colors.withHashtag.base0D}"
            inactive-color "${colors.withHashtag.base03}"
            urgent-color "${colors.withHashtag.base08}"
        }
        border {
            off
        }
    }

    ${lib.optionalString (cursor != null) ''
      cursor {
          xcursor-theme "${cursor.name}"
          xcursor-size ${toString cursor.size}
      }
    ''}

    // Windows have no title bars
    prefer-no-csd

    // The shell's wallpaper layer stays put while workspaces zoom out
    layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
    }
    overview {
        workspace-shadow {
            off
        }
    }

    hotkey-overlay {
        skip-at-startup
    }

    // Alt+Tab window switcher. Listed to drop niri's default Super+Tab,
    // which is the overview here (./binds.nix).
    recent-windows {
        binds {
            Alt+Tab         { next-window scope="output"; }
            Alt+Shift+Tab   { previous-window scope="output"; }
            Alt+grave       { next-window filter="app-id"; }
            Alt+Shift+grave { previous-window filter="app-id"; }
        }
    }

    window-rule {
        match app-id=r#"^org\.gnome\.Calculator$"#
        match app-id=r#"^xdg-desktop-portal"#
        match app-id=r#"^nm-connection-editor$"#
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    ${workspaceKdl}
    ${workspaceAppsKdl}
    include "binds.kdl"

    ${lib.concatMapStringsSep "\n" (f: ''include optional=true "dms/${f}.kdl"'') dmsFragments}
  '';

  niriConfig =
    pkgs.runCommand "niri-config"
      {
        nativeBuildInputs = [ pkgs.niri ];
        passAsFile = [
          "configKdl"
          "bindsKdl"
        ];
        inherit configKdl;
        bindsKdl = import ./binds.nix { inherit lib; };
      }
      ''
        mkdir $out
        cp $configKdlPath $out/config.kdl
        cp $bindsKdlPath $out/binds.kdl
        niri validate -c $out/config.kdl
      '';
in
{
  xdg.configFile = {
    "niri/config.kdl".source = "${niriConfig}/config.kdl";
    "niri/binds.kdl".source = "${niriConfig}/binds.kdl";
    "niri/dms".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/desktop/niri/config/niri-dms";
  };

  # Start the shell (../dux-shell) with the niri session
  systemd.user.targets.dux-shell.Install.WantedBy = [ "niri.service" ];
}
