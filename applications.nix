{
  config,
  pkgs,
  ...
}:
let
  # Bring in nixpkgs-unstable alongside your stable pkgs
  unstable = import <nixpkgs-unstable> {
    stdenv.hostPlatform.system = pkgs.system;
    config = config.nixpkgs.config;
  };
  nixpkgs-master =
    import
      (fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
      })
      {
        stdenv.hostPlatform.system = pkgs.system;
        config = config.nixpkgs.config;
      };

in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for sublime4
  ];

  environment.systemPackages = with pkgs; [
    home-manager

    # Code
    deno
    eslint
    jre
    nodejs_22
    sublime-merge
    sublime4
    nixpkgs-master.codex
    nixpkgs-master.codex-acp
    nixpkgs-master.claude-code
    nixpkgs-master.zed-editor
    yarn

    ## Rust
    gcc
    just
    rustup
    sqlx-cli
    pkg-config
    openssl.dev

    ### LSP / Editor util
    color-lsp
    shfmt
    sql-formatter
    yamlfmt

    # Tools
    bind
    git
    htop
    jq
    ncdu
    neovim
    nil
    nixd
    oh-my-zsh
    ripgrep
    wget
    wl-clipboard
    zsh

    # Work
    awscli2
    glab
    husky
    insomnia
    kubectl
    kubeseal
    unstable.mongodb-compass
    mongodb-tools
    postgresql
    vault

    # Applications
    rapidraw
    bitwarden-cli
    gnome-tweaks
    libreoffice
    microsoft-edge
    # (pkgs.microsoft-edge.override {
    #   commandLineArgs = "--ozone-platform=x11";
    # })
    spotify
    zoom-us
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      lilex
      # No real customization, just couldn't get the bundle of weights/styles I wanted
      (iosevka.override {
        set = "Ralphpig";
        privateBuildPlan = ''
          [buildPlans.IosevkaRalphpig]
          family = "Iosevka Ralphpig"
          spacing = "normal"
          serifs = "sans"
          noCvSs = true
          exportGlyphNames = false

          [buildPlans.IosevkaRalphpig.weights.Regular]
          shape = 400
          menu = 400
          css = 400

          [buildPlans.IosevkaRalphpig.weights.Bold]
          shape = 700
          menu = 700
          css = 700

          [buildPlans.IosevkaRalphpig.widths.Normal]
          shape = 600
          menu = 5
          css = "normal"

          [buildPlans.IosevkaRalphpig.slopes.Upright]
          angle = 0
          shape = "upright"
          menu = "upright"
          css = "normal"

          [buildPlans.IosevkaRalphpig.slopes.Italic]
          angle = 9.4
          shape = "italic"
          menu = "italic"
          css = "italic"
        '';
      })
      (iosevka.override {
        set = "RalphpigTerm";
        privateBuildPlan = ''
          [buildPlans.IosevkaRalphpigTerm]
          family = "Iosevka Ralphpig Term"
          spacing = "term"
          serifs = "sans"
          noCvSs = true
          exportGlyphNames = false

          [buildPlans.IosevkaRalphpigTerm.weights.Regular]
          shape = 400
          menu = 400
          css = 400

          [buildPlans.IosevkaRalphpigTerm.weights.Bold]
          shape = 700
          menu = 700
          css = 700

          [buildPlans.IosevkaRalphpigTerm.widths.Normal]
          shape = 600
          menu = 5
          css = "normal"

          [buildPlans.IosevkaRalphpigTerm.slopes.Upright]
          angle = 0
          shape = "upright"
          menu = "upright"
          css = "normal"

          [buildPlans.IosevkaRalphpigTerm.slopes.Italic]
          angle = 9.4
          shape = "italic"
          menu = "italic"
          css = "italic"
        '';
      })
      (iosevka.override {
        set = "RalphpigProportional";
        privateBuildPlan = ''
          [buildPlans.IosevkaRalphpigProportional]
          family = "Iosevka Ralphpig Proportional"
          spacing = "quasi-proportional"
          serifs = "sans"
          noCvSs = true
          exportGlyphNames = false

          [buildPlans.IosevkaRalphpigProportional.weights.Regular]
          shape = 400
          menu = 400
          css = 400

          [buildPlans.IosevkaRalphpigProportional.weights.Bold]
          shape = 700
          menu = 700
          css = 700

          [buildPlans.IosevkaRalphpigProportional.widths.Normal]
          shape = 600
          menu = 5
          css = "normal"

          [buildPlans.IosevkaRalphpigProportional.slopes.Upright]
          angle = 0
          shape = "upright"
          menu = "upright"
          css = "normal"

          [buildPlans.IosevkaRalphpigProportional.slopes.Italic]
          angle = 9.4
          shape = "italic"
          menu = "italic"
          css = "italic"
        '';
      })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Iosevka Ralphpig Proportional" ];
        sansSerif = [ "Iosevka Ralphpig Proportional" ];
        monospace = [ "Iosevka Ralphpig" ];
      };
    };
  };

  # Program Config
  programs.zsh = {
    enable = true;
  };
}
