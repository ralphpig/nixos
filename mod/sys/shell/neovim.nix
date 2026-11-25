{
  flake.modules.homeManager.base = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # No remote plugins in use; avoids pulling in ruby/python provider envs
      withRuby = false;
      withPython3 = false;
      extraConfig = ''
        set shiftwidth=2 smarttab
        set expandtab
        set tabstop=8 softtabstop=0
      '';
    };

    home.sessionVariables.EDITOR = "nvim";
  };
}
