# System-wide theming via Stylix, optional per host. Also auto-imports into every home-manager
# user (ralphpig, root), so GTK/GNOME shell/neovim/etc. pick it up too.
# Opt a single app out with `stylix.targets.<name>.enable = false;`.
#
# Fonts are set in ../sys/fonts.nix, next to the custom Iosevka builds. Other
# modules' Stylix settings live with them, guarded by `options ? stylix` so they
# work without it.
{ inputs, ... }:
{
  flake.modules.nixos.stylix =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

        # Wallpaper only; the palette comes from base16Scheme above. Stylix copies
        # this into the store. Also used by mod/feat/dux and GNOME's lock screen.
        image = ../../wallpapers/train_car.png;

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };

        # Stylix picks "gnome" on GNOME, but can only theme Qt apps via qtct
        # (qt5ct/qt6ct + Kvantum). Forced because its NixOS module sets it directly.
        targets.qt.platform = lib.mkForce "qtct";

        # Themed by hand in mod/sys/boot.nix
        targets.grub.enable = false;
        targets.plymouth.enable = false;

        # Overlays rebuild gnome-shell, gtksourceview and nixos-icons (and all
        # their dependents) from source on every scheme change. Only costs the
        # themed GDM login screen and recolored NixOS logo; the desktop shell is
        # themed via home-manager and gtksourceview styles via ~/.local/share.
        overlays.enable = false;
      };

      home-manager.sharedModules = [
        (
          { config, ... }:
          let
            # Stylix's GNOME Shell theme, rebuilt with two fixes:
            # - GNOME's stock dark $background_mix_factor (9%) instead of Stylix's
            #   0%. At 0%, unchecked buttons (e.g. quick settings toggles) are the
            #   exact same color as the menu behind them.
            # - Compile GNOME's dark stylesheet when polarity is dark. Stylix always
            #   compiles the light one, whose light-mode logic darkens things a
            #   dark theme should lighten (quick settings arrow buttons, hovers).
            variant = if config.stylix.polarity == "dark" then "dark" else "light";
            shellTheme =
              (pkgs.callPackage "${inputs.stylix}/modules/gnome/theme.nix" {
                inherit (config.lib.stylix) colors;
                inherit (inputs.stylix) inputs;
              }).overrideAttrs
                (old: {
                  postPatch = old.postPatch + ''
                    substituteInPlace data/theme/gnome-shell-sass/_colors.scss \
                      --replace-fail '$background_mix_factor: 0%;' '$background_mix_factor: 9%;'
                    # Only the dark stylesheet uses this (privacy indicator);
                    # Stylix's colors file just defines the light one ($orange_4)
                    echo '$orange_3: ${config.lib.stylix.colors.withHashtag.base09};' \
                      >>data/theme/gnome-shell-sass/_colors.scss
                  '';
                  # Same as Stylix's buildPhase, but with the chosen variant; the
                  # output is still named gnome-shell-light.css for its installPhase
                  buildPhase = ''
                    sass data/theme/gnome-shell-${variant}.scss \
                      >data/theme/gnome-shell-light.css
                    cp data/theme/gnome-shell-{light,dark}.css
                    glib-compile-resources \
                      --sourcedir=data/theme \
                      data/gnome-shell-theme.gresource.xml
                  '';
                });
          in
          lib.mkIf config.stylix.targets.gnome.enable {
            xdg.dataFile."themes/Stylix/gnome-shell/gnome-shell.css".source =
              lib.mkForce "${shellTheme}/share/gnome-shell/gnome-shell.css";
          }
        )
      ];
    };
}
