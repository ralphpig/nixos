# Desktop workstation: Intel CPU, AMD RX 9070 XT, ZFS on a single NVMe.
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./boot.nix

    ../../modules/core.nix
    ../../modules/services.nix
    ../../modules/fonts.nix

    ../../modules/packages/cli.nix
    ../../modules/packages/dev.nix
    ../../modules/packages/ai.nix
    ../../modules/packages/work.nix
    ../../modules/packages/apps.nix

    # ../../modules/llm/ollama.nix
    # ../../modules/llm/llama-cpp-prism.nix

    ../../desktop/gnome/nixos.nix
  ];

  networking.hostName = "ralphpig-nixos-zfs";

  # Windows (dual boot) expects local time
  time.hardwareClockInLocalTime = true;

  # Don't change ever
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";
}
