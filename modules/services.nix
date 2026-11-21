{ ... }:
{
  virtualisation.docker.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Printing, with IPP Everywhere auto-discovery
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
