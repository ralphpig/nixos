{
  description = "ralphpig's NixOS + home-manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dux Shell (formerly DankMaterialShell), the desktop shell for Hyprland/niri.
    # nixpkgs 26.05 only has 1.4.x; the stable branch tracks the latest 2.x.
    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elegant-grub2-themes = {
      url = "github:vinceliuice/Elegant-grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Every .nix file under mod/ is a flake-parts module, except paths starting
  # with "_".
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./mod);
}
