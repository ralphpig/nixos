# home-manager as a NixOS module: `nh os switch` applies system + home together.
{ inputs, username, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true; # same pkgs (overlays, allowUnfree) as the system
    useUserPackages = true; # install into /etc/profiles/per-user/<name>
    backupFileExtension = "hm-bak"; # rename conflicting files instead of failing
    extraSpecialArgs = { inherit inputs username; };

    users.${username} = import ../home/ralphpig.nix;
    users.root = import ../home/root.nix;
  };
}
