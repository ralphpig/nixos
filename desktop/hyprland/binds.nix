# Hyprland keybinds. Imported by ./home.nix.
#
# Each entry becomes an hl.bind(keys, dispatcher, opts) call in hyprland.lua.
# Dispatchers are Lua (https://wiki.hypr.land); shell actions go through
# `dms ipc call ...` (list them with `dms ipc call --help`).
# Super+Shift+/ shows them all in the shell's cheat sheet.
{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;

  exec = cmd: "hl.dsp.exec_cmd(${builtins.toJSON cmd})";
  shell = args: exec "dms ipc call ${args}";

  binds = {
    # Apps and shell
    "SUPER + Return" = exec "ghostty";
    "SUPER + space" = shell "spotlight toggle"; # launcher
    "SUPER + C" = shell "control-center toggle"; # quick settings
    "SUPER + X" = shell "powermenu toggle";
    "SUPER + TAB" = shell "hypr toggleOverview";
    "SUPER + V" = shell "clipboard toggle";
    "SUPER + N" = shell "notifications toggle";
    "SUPER + comma" = shell "settings focusOrToggle";
    "SUPER + SHIFT + Slash" = shell "keybinds toggle hyprland";
    "SUPER + ALT + L" = shell "lock lock";
    "CTRL + ALT + Delete" = shell "processlist focusOrToggle";
    "Print" = exec "dms screenshot";
    "CTRL + Print" = exec "dms screenshot full";
    "ALT + Print" = exec "dms screenshot window";

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
    "SUPER + Page_Up" = ''hl.dsp.focus({ workspace = "e-1" })'';
    "SUPER + Page_Down" = ''hl.dsp.focus({ workspace = "e+1" })'';
    "SUPER + mouse_up" = ''hl.dsp.focus({ workspace = "e-1" })'';
    "SUPER + mouse_down" = ''hl.dsp.focus({ workspace = "e+1" })'';
  }
  # Focus (Super) and move (Super+Shift) with arrows or hjkl
  // lib.concatMapAttrs (
    dir: keys:
    lib.concatMapAttrs (_: key: {
      "SUPER + ${key}" = ''hl.dsp.focus({ direction = "${dir}" })'';
      "SUPER + SHIFT + ${key}" = ''hl.dsp.window.move({ direction = "${dir}" })'';
    }) keys
  ) {
    l = { arrow = "left"; vim = "H"; };
    d = { arrow = "down"; vim = "J"; };
    u = { arrow = "up"; vim = "K"; };
    r = { arrow = "right"; vim = "L"; };
  }
  # Workspaces 1-9: go (Super) and send window (Super+Shift)
  // lib.concatMapAttrs (_: n: {
    "SUPER + ${n}" = ''hl.dsp.focus({ workspace = "${n}" })'';
    "SUPER + SHIFT + ${n}" = ''hl.dsp.window.move({ workspace = "${n}" })'';
  }) (lib.genAttrs (map toString (lib.range 1 9)) lib.id);

  # Media keys: work on the lock screen; volume repeats while held
  mediaBinds = {
    "XF86AudioRaiseVolume" = [ (shell "audio increment 3") { repeating = true; } ];
    "XF86AudioLowerVolume" = [ (shell "audio decrement 3") { repeating = true; } ];
    "XF86AudioMute" = [ (shell "audio mute") { } ];
    "XF86AudioMicMute" = [ (shell "audio micmute") { } ];
    "XF86AudioPlay" = [ (shell "mpris playPause") { } ];
    "XF86AudioPause" = [ (shell "mpris playPause") { } ];
    "XF86AudioNext" = [ (shell "mpris next") { } ];
    "XF86AudioPrev" = [ (shell "mpris previous") { } ];
  };

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
    ++ lib.mapAttrsToList (
      keys: v: mkBind keys (builtins.elemAt v 0) ({ locked = true; } // builtins.elemAt v 1)
    ) mediaBinds
    ++ lib.mapAttrsToList (keys: d: mkBind keys d { mouse = true; }) mouseBinds;
}
