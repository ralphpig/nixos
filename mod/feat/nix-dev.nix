# Nix language servers
{
  flake.modules.homeManager.nix-dev = { pkgs, ... }: {
    home.packages = with pkgs; [
      nil
      nixd
    ];
  };
}
