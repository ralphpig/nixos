# Keybinds that drive the shell rather than the compositor, shared by every
# compositor that runs it. Plain data; each compositor's binds.nix renders it
# in its own syntax (../hyprland/_binds.nix, ../niri/_binds.nix).
#
# Keys: modifiers (Super, Shift, Ctrl, Alt) and an xkb key name joined by "+".
# Commands: run through `sh -c`. Shell actions go through `dms ipc call ...`
# (list them with `dms ipc call --help`).
let
  ipc = args: "dms ipc call ${args}";
in
{
  # Plain binds
  commands = {
    "Super+Return" = "ghostty";
    "Super+space" = ipc "spotlight toggle"; # launcher
    "Super+C" = ipc "control-center toggle"; # quick settings
    "Super+X" = ipc "powermenu toggle";
    "Super+V" = ipc "clipboard toggle";
    "Super+N" = ipc "notifications toggle";
    "Super+comma" = ipc "settings focusOrToggle";
    "Super+Alt+L" = ipc "lock lock";
    "Ctrl+Alt+Delete" = ipc "processlist focusOrToggle";
    "Print" = "dms screenshot";
    "Ctrl+Print" = "dms screenshot full";
    "Alt+Print" = "dms screenshot window";
  };

  # Media keys: work on the lock screen; `repeat` ones repeat while held
  media = {
    "XF86AudioRaiseVolume" = {
      command = ipc "audio increment 3";
      repeat = true;
    };
    "XF86AudioLowerVolume" = {
      command = ipc "audio decrement 3";
      repeat = true;
    };
    "XF86AudioMute" = {
      command = ipc "audio mute";
      repeat = false;
    };
    "XF86AudioMicMute" = {
      command = ipc "audio micmute";
      repeat = false;
    };
    "XF86AudioPlay" = {
      command = ipc "mpris playPause";
      repeat = false;
    };
    "XF86AudioPause" = {
      command = ipc "mpris playPause";
      repeat = false;
    };
    "XF86AudioNext" = {
      command = ipc "mpris next";
      repeat = false;
    };
    "XF86AudioPrev" = {
      command = ipc "mpris previous";
      repeat = false;
    };
  };
}
