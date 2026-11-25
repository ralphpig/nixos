# home-manager as a NixOS module: `nh os switch` applies system + home together.
# The only home-manager plumbing; users are in mod/user.
{ config, inputs, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.base = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true; # same pkgs (overlays, allowUnfree) as the system
      useUserPackages = true; # install into /etc/profiles/per-user/<name>
      backupFileExtension = "hm-bak"; # rename conflicting files instead of failing
      sharedModules = [ hm.base ]; # every user, root included
    };
  };

  flake.modules.homeManager.base =
    { config, lib, ... }:
    {
      options.my.repoDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/nixos";
        description = ''
          Absolute path of this repo's checkout, for live (out-of-store)
          ~/.config symlinks. Targets must be absolute string paths: a Nix
          path (./config) would resolve to the read-only store copy.
        '';
      };

      config.programs.home-manager.enable = true;
    };
}
