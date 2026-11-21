# App configs that the apps themselves edit (zed/sublime settings UIs), so
# they're symlinked live into this repo rather than copied read-only into
# the store. Edits show up in `git diff`; no rebuild needed.
#
# Requires the repo checked out at ~/nixos. Targets must be absolute string
# paths: a Nix path (./config/zed) would resolve to the read-only store copy.
{ config, ... }:
let
  repoDir = "${config.home.homeDirectory}/nixos";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/config/${path}";
  linkConfig = path: {
    name = path;
    value.source = link path;
  };
in
{
  xdg.configFile = builtins.listToAttrs (
    map linkConfig [
      "zed"
      "sql-formatter"
      "sublime-text/Packages/User"
      "sublime-text/Packages/sql-formatter"
      "sublime-merge/Packages/User"
    ]
  );
}
