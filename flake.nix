{
  description = "ralphpig's NixOS + home-manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      username = "ralphpig";
    in
    {
      nixosConfigurations.ralphpig-nixos-zfs = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username; };
        modules = [ ./hosts/ralphpig-nixos-zfs ];
      };
    };
}
