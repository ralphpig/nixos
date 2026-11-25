# Dux Shell, shared by the compositors that run it (../hyprland, ../niri).
# Features don't import each other, so list dux next to them in the host and
# user.
#
# Dux Shell is the whole desktop: bar, launcher, notifications, control center,
# OSD, lock screen, idle/suspend and polkit agent. Nothing else is needed for
# those (no waybar, mako, swaylock, hypridle, polkit agents...).
#
# Who owns what:
# - Nix: the shell's package and service, and the Stylix theme file (./stylix.nix).
#   Compositor-specific parts (its config, keybinds, the shell's fragments for
#   it) live with the compositor (../hyprland, ../niri).
# - Dotfiles in ./config, symlinked live (the shell's
#   Settings app edits them; changes show up in `git diff`, no rebuild):
#     ./config/dms -> ~/.config/dms (settings.json, one for every compositor)
#   The whole directory is linked because the shell saves by writing a temp
#   file and renaming it over the old one, which would replace a per-file
#   symlink with a plain file.
# - Both: my.dux.settings (with Stylix: theme, fonts) is merged into
#   settings.json on every rebuild, overriding what the UI set for those keys.
#   All settings keys and their defaults: quickshell/Common/settings/
#   SettingsSpec.js in the shell's source (or change one in the UI and look
#   at `git diff`).
#
# Starting it: the service is wanted by dux-shell.target, which each
# compositor pulls into its own session (not graphical-session.target, which
# GNOME reaches too).
{ inputs, ... }:
{
  flake.modules.nixos.dux =
    { pkgs, ... }:
    {
      # The compositors' portals only do screen sharing/screenshots; the GTK one
      # covers file pickers and the rest.
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # What the shell's widgets talk to. GNOME already enables these; listed so
      # the shell doesn't depend on it.
      services.gnome.gnome-keyring.enable = true;
      services.power-profiles-daemon.enable = true;
      services.accounts-daemon.enable = true;
      services.upower.enable = true;
      services.geoclue2.enable = true; # night light schedule / weather location

      # Electron/Chromium apps (Edge, Spotify, Zed...) run natively on Wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };

  flake.modules.homeManager.dux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.dux;
      json = pkgs.formats.json { };
      settingsFile = pkgs.writeText "dms-settings.json" (builtins.toJSON cfg.settings);
      sessionFile = pkgs.writeText "dms-session.json" (builtins.toJSON cfg.session);
    in
    {
      imports = [ inputs.dms.homeModules.default ];

      options.my.dux = {
        settings = lib.mkOption {
          inherit (json) type;
          default = { };
          description = "Merged into settings.json on every rebuild (Nix wins for these keys).";
        };
        session = lib.mkOption {
          inherit (json) type;
          default = { };
          description = ''
            Merged into session.json (runtime state, not tracked) on every rebuild.
            Nix wins over what was picked in the shell for these keys.
          '';
        };
      };

      config = {
        # The dock's pinned apps, same as GNOME's dash. Keyed by the dock's id
        # in settings.json (dockConfigs); pins are desktop file names without
        # .desktop.
        my.dux.session.dockPins.dock = map (lib.removeSuffix ".desktop") (import ../_favorite-apps.nix);

        programs.dank-material-shell = {
          enable = true;

          # One package for every compositor, so all source patches go here. Each
          # fails to build if upstream changes the line; then check whether it's
          # fixed there and drop it.
          #
          # DPopout (Hyprland): clicking a bar widget again without moving the mouse
          # reopened its popout instead of closing it. While a popout is open,
          # Hyprland only delivers clicks to an allow-list of the shell's surfaces;
          # the bar was only on it once the popout had keyboard focus, which with
          # focus-follows-mouse needs pointer motion. So the click counted as
          # "outside" (closing the popout) and also reached the bar (reopening it).
          # Keep the bar on the list. Only Hyprland uses it.
          #
          # MprisController: use a stopped player when there's no other, so the media
          # key and bar widget work with a freshly opened Spotify/Spotifast (stopped
          # until something plays).
          package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell.overrideAttrs (old: {
            postInstall = old.postInstall + ''
              substituteInPlace $out/share/quickshell/dms/Widgets/DPopout.qml --replace-fail \
                'return list.concat(transientWindows);' \
                'return list.concat(transientWindows).concat(KeyboardFocus.barWindows);'
              substituteInPlace $out/share/quickshell/dms/Services/MprisController.qml --replace-fail \
                'availablePlayers.find(p => p.canControl && !isIdle(p)) ?? null;' \
                'availablePlayers.find(p => p.canControl && !isIdle(p)) ?? availablePlayers.find(p => p.canControl) ?? null;'
            '';
          });

          systemd = {
            enable = true;
            target = "dux-shell.target";
          };
        };

        # Started by the compositors' sessions: each adds its session unit to
        # Install.WantedBy. Stops with the graphical session on logout.
        systemd.user.targets.dux-shell.Unit = {
          Description = "Dux Shell session";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        xdg.configFile."dms".source =
          config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/dux/config/dms";

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
          merge "${config.xdg.configHome}/dms/settings.json" ${settingsFile}
          merge "${config.xdg.stateHome}/dms/session.json" ${sessionFile}
        '';

        # The shell's network UI only connects/disconnects. For editing connections
        # (VPN import, split tunnel, credentials): nm-connection-editor ("Advanced
        # Network Configuration" in the launcher), or GNOME's `gnome-control-center network`.
        home.packages = [ pkgs.networkmanagerapplet ];
      };
    };
}
