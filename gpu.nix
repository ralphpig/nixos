{ ... }:
{
  # Enable OpenGL/Vulkan. Mesa (radeonsi + RADV + VA-API) is included by
  # default, so no extraPackages are needed for a plain desktop.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
