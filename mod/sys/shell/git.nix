{
  flake.modules.homeManager.base = {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Mike";
        email = "mail@ralphpig.dev";
      };
    };
  };
}
