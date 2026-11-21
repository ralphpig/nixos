{ pkgs, ... }:
let
  # Custom Iosevka builds. No real customization, just couldn't get the bundle
  # of weights/styles I wanted. Only `set`, `family` and `spacing` differ.
  # NOTE: any change to the generated plan text triggers a (long) rebuild.
  mkIosevka =
    {
      set,
      family,
      spacing,
    }:
    pkgs.iosevka.override {
      inherit set;
      privateBuildPlan = ''
        [buildPlans.Iosevka${set}]
        family = "${family}"
        spacing = "${spacing}"
        serifs = "sans"
        noCvSs = true
        exportGlyphNames = false

        [buildPlans.Iosevka${set}.weights.Regular]
        shape = 400
        menu = 400
        css = 400

        [buildPlans.Iosevka${set}.weights.Bold]
        shape = 700
        menu = 700
        css = 700

        [buildPlans.Iosevka${set}.widths.Normal]
        shape = 600
        menu = 5
        css = "normal"

        [buildPlans.Iosevka${set}.slopes.Upright]
        angle = 0
        shape = "upright"
        menu = "upright"
        css = "normal"

        [buildPlans.Iosevka${set}.slopes.Italic]
        angle = 9.4
        shape = "italic"
        menu = "italic"
        css = "italic"
      '';
    };
in
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      lilex
      (mkIosevka {
        set = "Ralphpig";
        family = "Iosevka Ralphpig";
        spacing = "normal";
      })
      (mkIosevka {
        set = "RalphpigTerm";
        family = "Iosevka Ralphpig Term";
        spacing = "term";
      })
      (mkIosevka {
        set = "RalphpigProportional";
        family = "Iosevka Ralphpig Proportional";
        spacing = "quasi-proportional";
      })
    ];

    fontconfig.defaultFonts = {
      serif = [ "Iosevka Ralphpig Proportional" ];
      sansSerif = [ "Iosevka Ralphpig Proportional" ];
      monospace = [ "Iosevka Ralphpig" ];
    };
  };
}
