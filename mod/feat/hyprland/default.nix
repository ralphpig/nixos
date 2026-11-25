# Hyprland. Adds a "Hyprland" session to GDM's session menu. The shell itself (package,
# service, theme, settings.json) is ../dux, which must be enabled too.
#
# Who owns what:
# - Nix: ~/.config/hypr/hyprland.lua (base config, below, plus keybinds from
#   ./_binds.nix).
# - Dotfiles in ./config, symlinked live (the shell's
#   Settings app edits them; changes show up in `git diff`, no rebuild):
#     ./config/hypr-dms -> ~/.config/hypr/dms  (monitors, input, layout,
#                                               window rules, binds-user)
#   The whole directory is linked; ../dux says why.
{
  flake.modules.nixos.hyprland = {
    # Session file for GDM, xdg-desktop-portal-hyprland, polkit, dconf.
    # Not using UWSM: home-manager's hyprland-session.target (the home half) is
    # what starts the shell.
    programs.hyprland.enable = true;
  };

  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      options,
      ...
    }:
    let
      # Fragments the shell writes into ~/.config/hypr/dms/, in its stock order.
      # Not its binds.lua: keybinds are in ./_binds.nix.
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
      imports = [ ./_binds.nix ];

      config = {

        # Start the shell (../dux) with the Hyprland session
        systemd.user.targets.dux-shell.Install.WantedBy = [ "hyprland-session.target" ];

        xdg.configFile."hypr/dms".source =
          config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/hyprland/config/hypr-dms";

        wayland.windowManager.hyprland = {
          enable = true;
          # Use the NixOS module's Hyprland and portal (the system half)
          package = null;
          portalPackage = null;
          # Dux Shell 2.x only speaks Hyprland's Lua config
          configType = "lua";
          # Starts hyprland-session.target, which starts the shell via
          # dux-shell.target (systemd.enable is on by default)

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
      // lib.optionalAttrs (options ? stylix) {
        stylix.targets.hyprland.hyprpaper.enable = false; # the shell draws the wallpaper
      };
    };
}
