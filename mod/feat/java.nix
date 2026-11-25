# Java
{
  flake.modules.homeManager.java = { pkgs, ... }: {
    home.packages = with pkgs; [
      jre
    ];
  };
}
