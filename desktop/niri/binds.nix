# niri keybinds, as the KDL `binds` section. Imported by ./home.nix.
#
# Actions: https://yalter.github.io/niri/Configuration:-Key-Bindings
# The shell's binds (launcher, quick settings, media keys...) are shared with
# other compositors in ../dux-shell/binds.nix and rendered here.
# Super+Shift+/ shows them all in the shell's cheat sheet.
#
# niri lays windows out in columns on an endless horizontal strip, one strip
# per workspace; workspaces stack vertically, with an empty one always at the
# bottom. Super+drag moves a window, Super+right-drag resizes (built in).
{ lib }:
let
  shellBinds = import ../dux-shell/binds.nix;

  spawn = cmd: "spawn-sh ${builtins.toJSON cmd};";

  binds =
    lib.mapAttrs (_: spawn) shellBinds.commands
    // {
      "Super+Tab" = "toggle-overview;";
      "Super+Shift+slash" = spawn "dms ipc call keybinds toggle niri";

      # Windows
      "Super+Q" = "close-window;";
      "Super+Shift+Q" = "close-window;"; # GNOME's
      "Super+F" = "maximize-column;";
      "Super+Shift+F" = "fullscreen-window;";
      "Super+Shift+T" = "toggle-window-floating;";
      "Super+Ctrl+T" = "switch-focus-between-floating-and-tiling;";

      # Columns: cycle preset widths (1/3, 1/2, 2/3), nudge width, center
      "Super+R" = "switch-preset-column-width;";
      "Super+Shift+R" = "switch-preset-window-height;";
      "Super+minus" = ''set-column-width "-10%";'';
      "Super+equal" = ''set-column-width "+10%";'';
      "Super+Ctrl+C" = "center-column;";
      # Stack windows into a column / back out, and show a column as tabs
      "Super+bracketleft" = "consume-or-expel-window-left;";
      "Super+bracketright" = "consume-or-expel-window-right;";
      "Super+W" = "toggle-column-tabbed-display;";

      # Previous/next workspace (up/down). Super+A/D as in GNOME.
      "Super+A" = "focus-workspace-up;";
      "Super+D" = "focus-workspace-down;";
      "Super+Shift+A" = "move-column-to-workspace-up;";
      "Super+Shift+D" = "move-column-to-workspace-down;";
      "Super+Page_Up" = "focus-workspace-up;";
      "Super+Page_Down" = "focus-workspace-down;";
      "Super+Ctrl+Page_Up" = "move-workspace-up;";
      "Super+Ctrl+Page_Down" = "move-workspace-down;";
      # Wheel: workspaces; with Shift, columns
      "Super+WheelScrollUp cooldown-ms=150" = "focus-workspace-up;";
      "Super+WheelScrollDown cooldown-ms=150" = "focus-workspace-down;";
      "Super+Shift+WheelScrollUp" = "focus-column-left;";
      "Super+Shift+WheelScrollDown" = "focus-column-right;";
      "Super+Home" = "focus-column-first;";
      "Super+End" = "focus-column-last;";
    }
    # Focus (Super) and move (Super+Shift) with arrows or hjkl. Up/down go
    # past the top/bottom window of a column to the next workspace.
    //
      lib.concatMapAttrs
        (
          _:
          {
            keys,
            focus,
            move,
          }:
          lib.mergeAttrsList (
            map (key: {
              "Super+${key}" = "${focus};";
              "Super+Shift+${key}" = "${move};";
            }) keys
          )
        )
        {
          l = {
            keys = [
              "Left"
              "H"
            ];
            focus = "focus-column-left";
            move = "move-column-left";
          };
          d = {
            keys = [
              "Down"
              "J"
            ];
            focus = "focus-window-or-workspace-down";
            move = "move-window-down-or-to-workspace-down";
          };
          u = {
            keys = [
              "Up"
              "K"
            ];
            focus = "focus-window-or-workspace-up";
            move = "move-window-up-or-to-workspace-up";
          };
          r = {
            keys = [
              "Right"
              "L"
            ];
            focus = "focus-column-right";
            move = "move-column-right";
          };
        }
    # Workspaces 1-10 (key 0 is 10): go (Super) and send column (Super+Shift)
    // lib.concatMapAttrs (key: n: {
      "Super+${key}" = "focus-workspace ${n};";
      "Super+Shift+${key}" = "move-column-to-workspace ${n};";
    }) (lib.genAttrs (map toString (lib.range 1 9)) lib.id // { "0" = "10"; });

  # Media keys: also on the lock screen. niri repeats held keys by default.
  mediaBinds = lib.mapAttrs' (
    key: v:
    lib.nameValuePair "${key} allow-when-locked=true${lib.optionalString (!v.repeat) " repeat=false"}" (
      spawn v.command
    )
  ) shellBinds.media;
in
''
  binds {
  ${lib.concatStrings (lib.mapAttrsToList (k: a: "    ${k} { ${a} }\n") (binds // mediaBinds))}}
''
