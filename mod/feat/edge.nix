{
  flake.modules.homeManager.edge = { pkgs, ... }: {
    home.packages = with pkgs; [
      microsoft-edge
    ];
  };
}
