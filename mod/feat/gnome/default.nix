# GNOME on GDM.
{
  flake.modules.nixos.gnome = {
    services.xserver = {
      enable = true;

      # X11 only; GNOME (Wayland) takes repeat rate from dconf instead
      displayManager.sessionCommands = ''
        xset r rate 200 30
      '';

      xkb.layout = "us";
      # xkb.options = "eurosign:e,caps:escape";
    };

    services.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
      '';
    };

    services.displayManager = {
      gdm.enable = true;
    };

  };

  flake.modules.homeManager.gnome =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    with lib.hm.gvariant;
    let
      hasStylix = options ? stylix;
      # Same image Stylix uses for the desktop background (../stylix.nix)
      wallpaper = "file://${config.stylix.image}";
    in
    {
      home.packages = [
        pkgs.gnome-tweaks
      ]
      ++ (with pkgs.gnomeExtensions; [
        vitals
        windownavigator
        places-status-indicator
      ]);

      # Terminal (Super+Return below) is Ghostty, configured in ../ghostty.nix

      dconf.settings = {
        # Appearance
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
          clock-show-seconds = true;
          clock-format = "12h";
          # Superseded by Stylix (polarity, shell theme, stylix.fonts)
          # color-scheme = "prefer-dark";
          accent-color = "red"; # Stylix's shell theme still uses GNOME's accent
          # font-name = "Iosevka Ralphpig Proportional 11";
          # document-font-name = "Iosevka Ralphpig Proportional 11";
          # monospace-font-name = "Iosevka Ralphpig 11";
        };
        "org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };
        "org/gtk/settings/file-chooser" = {
          clock-format = "12h";
        };
        "org/gnome/mutter" = {
          dynamic-workspaces = false;
          workspaces-only-on-primary = true;
        };
        "org/gnome/desktop/wm/preferences" = {
          num-workspaces = 10;
          focus-mode = "sloppy";
        };
        "org/gnome/shell/app-switcher" = {
          current-workspace-only = true;
        };

        ## Wallpaper
        # Superseded by stylix.image (../stylix.nix)
        # "org/gnome/desktop/background" = {
        #   picture-uri = wallpaper;
        #   picture-uri-dark = wallpaper;
        #   primary-color = "#000000000000";
        #   secondary-color = "#000000000000";
        # };
        "org/gnome/desktop/screensaver" = lib.mkIf hasStylix {
          picture-uri = wallpaper;
          primary-color = "#000000000000";
          secondary-color = "#000000000000";
        };

        "org/gnome/shell" = {
          last-selected-power-profile = "performance";
          # GNOME hides Log Out when there's only one user; needed to get back to
          # GDM's session picker (GNOME <-> Hyprland)
          always-show-log-out = true;
          favorite-apps = import ../_favorite-apps.nix; # shared with Dux Shell's dock

          # Extensions
          disable-user-extensions = false;
          enabled-extensions =
            with pkgs.gnomeExtensions;
            [
              places-status-indicator.extensionUuid
              windownavigator.extensionUuid
              vitals.extensionUuid
            ]
            # Stylix shell theme; stylix installs the package
            ++ lib.optional hasStylix user-themes.extensionUuid;
        };

        # Extension Config
        "org/gnome/shell/extensions/vitals" = {
          hot-sensors = [
            "_processor_usage_"
            "_memory_usage_"
            "_storage_free_"
            "_memory_swap_usage_"
          ];
        };

        # Not used
        "org/gnome/shell/extensions/system-monitor" = {
          show-upload = false;
          show-download = false;
        };

        # Display
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = mkDouble 17.0;
          night-light-schedule-to = mkDouble 6.0;
          night-light-temperature = mkUint32 3700;
        };

        # Keyboard
        "org/gnome/desktop/peripherals/keyboard" = {
          delay = mkUint32 200;
          repeat-interval = mkUint32 30;
        };

        # Keybindings
        # "org/gnome/desktop/input-sources" = {
        #  xkb-options = ["altwin:swap_alt_win"]; # Swap Super to Alt
        # };

        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-left = [ "<Super>a" ];
          switch-to-workspace-right = [ "<Super>d" ];
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];
          switch-to-workspace-7 = [ "<Super>7" ];
          switch-to-workspace-8 = [ "<Super>8" ];
          switch-to-workspace-9 = [ "<Super>9" ];

          close = [ "<Shift><Super>q" ];
        };
        "org/gnome/shell/keybindings" = {
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
          switch-to-application-5 = [ ];
          switch-to-application-6 = [ ];
          switch-to-application-7 = [ ];
          switch-to-application-8 = [ ];
          switch-to-application-9 = [ ];
        };

        "org/gnome/mutter/keybindings" = {
          # disable <Super>p display type switching
          switch-monitor = [ "XF86Display" ];
        };

        # Custom Keybinds
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Open Terminal";
          binding = "<Super>Return";
          command = "ghostty";
        };
      };
    };
}
