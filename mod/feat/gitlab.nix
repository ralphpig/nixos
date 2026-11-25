# GitLab CLI
{
  flake.modules.homeManager.gitlab = { pkgs, ... }: {
    home.packages = with pkgs; [
      glab
    ];
  };
}
