{
  flake.modules.nixos.docker = {
    # Users also need the "docker" group (mod/user).
    virtualisation.docker.enable = true;
  };
}
