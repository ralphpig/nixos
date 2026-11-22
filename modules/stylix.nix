# System-wide theming via Stylix. Also auto-imports into every home-manager
# user (ralphpig, root), so GTK/GNOME shell/neovim/etc. pick it up too.
# Opt a single app out with `stylix.targets.<name>.enable = false;`.
#
# Fonts are set in ./fonts.nix, next to the custom Iosevka builds.
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

    # Wallpaper only; the palette comes from base16Scheme above. Stylix copies
    # this into the store (replaces the live-path wallpaper in desktop/gnome).
    image = ../wallpapers/landscape/prairie-mountain-tree.png;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    # Stylix picks "gnome" on GNOME, but can only theme Qt apps via qtct
    # (qt5ct/qt6ct + Kvantum). Forced because its NixOS module sets it directly.
    targets.qt.platform = lib.mkForce "qtct";

    # Themed by hand in hosts/ralphpig-nixos-zfs/boot.nix
    targets.grub.enable = false;
    targets.plymouth.enable = false;
  };

  home-manager.sharedModules = [
    (
      { config, ... }:
      let
        # Stylix's GNOME Shell theme, rebuilt with GNOME's stock dark
        # $background_mix_factor (9%) instead of Stylix's 0%. At 0%, unchecked
        # buttons (e.g. quick settings toggles) are the exact same color as
        # the menu behind them, so they look like they have no background.
        shellTheme =
          (pkgs.callPackage "${inputs.stylix}/modules/gnome/theme.nix" {
            inherit (config.lib.stylix) colors;
            inherit (inputs.stylix) inputs;
          }).overrideAttrs
            (old: {
              postPatch = old.postPatch + ''
                substituteInPlace data/theme/gnome-shell-sass/_colors.scss \
                  --replace-fail '$background_mix_factor: 0%;' '$background_mix_factor: 9%;'
              '';
            });
      in
      lib.mkIf config.stylix.targets.gnome.enable {
        xdg.dataFile."themes/Stylix/gnome-shell/gnome-shell.css".source =
          lib.mkForce "${shellTheme}/share/gnome-shell/gnome-shell.css";
      }
    )
  ];
}
