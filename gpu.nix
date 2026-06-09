{ config, pkgs, ... }:
let
  pkgsUnstable = import <nixpkgs-unstable> {
    stdenv.hostPlatform.system = pkgs.system;
    config = config.nixpkgs.config;
  };
in
{
  boot.kernelPackages = pkgsUnstable.linuxPackages_latest;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # Allow GPU for plymouth in stage 1
  # boot.initrd.availableKernelModules = ["nvidia"];

  hardware.nvidia = {
    nvidiaSettings = true;

    # Modesetting is required.
    modesetting.enable = true;

    # "Helps" fix suspend/awake issues, but causes freezing
    powerManagement.enable = false;
    nvidiaPersistenced = true;

    # 1080ti does not support
    powerManagement.finegrained = false;
    open = false;

    # 580 is last official support for Pascal arch (1080ti)
    # https://forums.developer.nvidia.com/t/unix-graphics-feature-deprecation-schedule/60588
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  boot.kernelParams = [
    "ibt=off" # Allegedly helps 10-series NVIDIA + Intel work better?

    # Already set by modesetting.enable
    # "nvidia-drm.modeset=1"
    # "nvidia-drm.fbdev=1"

    # Pascal stability workaround; only meaningful with open = false.
    "nvidia.NVreg_EnableGpuFirmware=0"

    "nvidia.NVreg_UsePageAttributeTable=1"
  ];

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_SYNC_TO_VBLANK = "1";

    MUTTER_DEBUG_DISABLE_TRIPLE_BUFFERING = "1";
  };
}
