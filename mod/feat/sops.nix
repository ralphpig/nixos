# SOPS secrets
{
  flake.modules.homeManager.sops = { pkgs, ... }: {
    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
    ];
  };
}
