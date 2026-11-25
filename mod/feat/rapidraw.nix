{
  flake.modules.homeManager.rapidraw = { pkgs, ... }: {
    home.packages = with pkgs; [
      rapidraw
    ];
  };
}
