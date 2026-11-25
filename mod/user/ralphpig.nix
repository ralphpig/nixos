{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.user-ralphpig = {
    users.users.ralphpig = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
    };

    home-manager.users.ralphpig = {
      # The home half of features. Ones with a system half too must also be
      # listed by the host.
      imports = with hm; [
        # Desktop
        dux
        gnome
        hyprland
        niri

        # Apps
        bitwarden
        edge
        ghostty
        insomnia
        libreoffice
        rapidraw
        spotifast
        spotify
        sublime
        zed
        zoom

        # Dev
        ai
        cloud
        database
        formatters
        gitlab
        java
        js
        k8s
        nix-dev
        rust
        sops
        sql-formatter

        # llama-cpp-prism
      ];

      # Don't change: see `home.stateVersion` in the home-manager manual.
      home.stateVersion = "24.05";
    };
  };
}
