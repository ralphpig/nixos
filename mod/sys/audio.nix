{
  flake.modules.nixos.base = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

  };
}
