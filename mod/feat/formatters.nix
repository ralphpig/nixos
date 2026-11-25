# Standalone code formatters
{
  flake.modules.homeManager.formatters = { pkgs, ... }: {
    home.packages = with pkgs; [
      pgformatter
      shfmt
      yamlfmt
    ];
  };
}
