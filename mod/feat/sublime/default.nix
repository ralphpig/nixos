# Sublime Text and Sublime Merge.
# The config is symlinked live into this repo (the app edits it itself):
# changes show up in `git diff`, no rebuild. See my.repoDir.
{
  flake.modules.nixos.sublime = {
    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w" # for sublime4
    ];
  };

  flake.modules.homeManager.sublime = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      sublime4
      unstable.sublime-merge-dev
    ];
    xdg.configFile = {
      "sublime-text/Packages/User".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/sublime/config/sublime-text/Packages/User";
      "sublime-text/Packages/sql-formatter".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/sublime/config/sublime-text/Packages/sql-formatter";
      "sublime-merge/Packages/User".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.repoDir}/mod/feat/sublime/config/sublime-merge/Packages/User";
    };
  };
}
