# Hyprland keybinds. Imported by ./home.nix.
#
# Each entry becomes an hl.bind(keys, dispatcher, opts) call in hyprland.lua.
# Dispatchers are Lua (https://wiki.hypr.land). The shell's binds (launcher,
# quick settings, media keys...) are shared with other compositors in
# ../dux-shell/binds.nix and rendered here.
# Super+Shift+/ shows them all in the shell's cheat sheet.
{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;

  shellBinds = import ../dux-shell/binds.nix;

  exec = cmd: "hl.dsp.exec_cmd(${builtins.toJSON cmd})";

  # "Super+Shift+A" -> "SUPER + SHIFT + A"
  hyprKeys =
    combo:
    lib.concatMapStringsSep " + " (
      k:
      if
        lib.elem k [
          "Super"
          "Shift"
          "Ctrl"
          "Alt"
        ]
      then
        lib.toUpper k
      else
        k
    ) (lib.splitString "+" combo);

  binds =
    lib.mapAttrs' (k: cmd: lib.nameValuePair (hyprKeys k) (exec cmd)) shellBinds.commands
    // {
      "SUPER + TAB" = exec "dms ipc call hypr toggleOverview";
      "SUPER + SHIFT + Slash" = exec "dms ipc call keybinds toggle hyprland";

      # Windows
      "SUPER + Q" = "hl.dsp.window.close()";
      "SUPER + SHIFT + Q" = "hl.dsp.window.close()"; # GNOME's
      "SUPER + F" = ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })'';
      "SUPER + SHIFT + F" = ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'';
      "SUPER + SHIFT + T" = ''hl.dsp.window.float({ action = "toggle" })'';
      "SUPER + R" = ''hl.dsp.layout("togglesplit")'';
      "SUPER + S" = "hl.dsp.workspace.toggle_special()"; # scratchpad
      "SUPER + SHIFT + S" = ''hl.dsp.window.move({ workspace = "special", follow = false })'';

      # Previous/next workspace. Super+A/D as in GNOME: by number, so empty
      # workspaces aren't skipped.
      "SUPER + A" = ''hl.dsp.focus({ workspace = "r-1" })'';
      "SUPER + D" = ''hl.dsp.focus({ workspace = "r+1" })'';
      "SUPER + SHIFT + A" = ''hl.dsp.window.move({ workspace = "r-1" })'';
      "SUPER + SHIFT + D" = ''hl.dsp.window.move({ workspace = "r+1" })'';
      "SUPER + Page_Up" = ''hl.dsp.focus({ workspace = "e-1" })'';
      "SUPER + Page_Down" = ''hl.dsp.focus({ workspace = "e+1" })'';
      "SUPER + mouse_up" = ''hl.dsp.focus({ workspace = "e-1" })'';
      "SUPER + mouse_down" = ''hl.dsp.focus({ workspace = "e+1" })'';
    }
    # Focus (Super) and move (Super+Shift) with arrows or hjkl
    //
      lib.concatMapAttrs
        (
          dir: keys:
          lib.concatMapAttrs (_: key: {
            "SUPER + ${key}" = ''hl.dsp.focus({ direction = "${dir}" })'';
            "SUPER + SHIFT + ${key}" = ''hl.dsp.window.move({ direction = "${dir}" })'';
          }) keys
        )
        {
          l = {
            arrow = "left";
            vim = "H";
          };
          d = {
            arrow = "down";
            vim = "J";
          };
          u = {
            arrow = "up";
            vim = "K";
          };
          r = {
            arrow = "right";
            vim = "L";
          };
        }
    # Workspaces 1-10 (key 0 is 10): go (Super) and send window (Super+Shift)
    // lib.concatMapAttrs (key: n: {
      "SUPER + ${key}" = ''hl.dsp.focus({ workspace = "${n}" })'';
      "SUPER + SHIFT + ${key}" = ''hl.dsp.window.move({ workspace = "${n}" })'';
    }) (lib.genAttrs (map toString (lib.range 1 9)) lib.id // { "0" = "10"; });

  # Windows have no title bars: Super+drag moves, Super+right-drag resizes
  mouseBinds = {
    "SUPER + mouse:272" = "hl.dsp.window.drag()";
    "SUPER + mouse:273" = "hl.dsp.window.resize()";
  };

  mkBind = keys: dispatcher: opts: {
    _args = [
      keys
      (mkLuaInline dispatcher)
    ]
    ++ lib.optional (opts != { }) opts;
  };
in
{
  wayland.windowManager.hyprland.settings.bind =
    lib.mapAttrsToList (keys: d: mkBind keys d { }) binds
    # Media keys: also on the lock screen
    ++ lib.mapAttrsToList (
      k: v:
      mkBind (hyprKeys k) (exec v.command) (
        { locked = true; } // lib.optionalAttrs v.repeat { repeating = true; }
      )
    ) shellBinds.media
    ++ lib.mapAttrsToList (keys: d: mkBind keys d { mouse = true; }) mouseBinds;
}
