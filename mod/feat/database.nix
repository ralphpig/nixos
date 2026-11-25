# Database clients
{
  flake.modules.homeManager.database = { pkgs, ... }: {
    home.packages = with pkgs; [
      mongodb-tools
      unstable.mongodb-compass
      pgcli
      postgresql
    ];
  };
}
