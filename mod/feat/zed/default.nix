# Zed editor
# The config is symlinked live into this repo (the app edits it itself):
# changes show up in `git diff`, no rebuild. See my.repoDir.
{
  flake.modules.homeManager.zed = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      zed-editor
      color-lsp
    ];
    xdg.configFile."zed".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/zed/config";
  };
}
