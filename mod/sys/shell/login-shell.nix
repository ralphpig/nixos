{
  flake.modules.nixos.base = { pkgs, ... }: {
    programs.zsh.enable = true; # registers zsh as a login shell
    users.defaultUserShell = pkgs.zsh;
  };
}
