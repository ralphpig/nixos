{
  flake.modules.nixos.base = {
    # Printing, with IPP Everywhere auto-discovery
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
