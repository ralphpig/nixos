# sql-formatter (also used by Sublime, see ../sublime)
# The config is symlinked live into this repo (the app edits it itself):
# changes show up in `git diff`, no rebuild. See my.repoDir.
{
  flake.modules.homeManager.sql-formatter = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      sql-formatter
    ];
    xdg.configFile."sql-formatter".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/sql-formatter/config";
  };
}
