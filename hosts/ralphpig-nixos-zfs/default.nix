# Desktop workstation: Intel CPU, AMD RX 9070 XT, ZFS on a single NVMe.
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./boot.nix

    ../../modules/core.nix
    ../../modules/home-manager.nix
    ../../modules/services.nix
    ../../modules/fonts.nix
    ../../modules/stylix.nix

    ../../modules/packages/cli.nix
    ../../modules/packages/dev.nix
    ../../modules/packages/ai.nix
    ../../modules/packages/work.nix
    ../../modules/packages/apps.nix

    # ../../modules/llm/ollama.nix
    # ../../modules/llm/llama-cpp-prism.nix

    # All desktops are installed; switch by logging out and picking one from
    # GDM's session menu (gear icon). GDM itself lives in the GNOME module.
    ../../desktop/gnome/nixos.nix
    ../../desktop/hyprland/nixos.nix
    ../../desktop/niri/nixos.nix
  ];

  # Session GDM autologins into at boot ("gnome", "hyprland" or "niri"). Set to null
  # to autologin into whichever session was used last instead.
  services.displayManager.defaultSession = "gnome";

  networking.hostName = "ralphpig-nixos-zfs";

  # Windows (dual boot) expects local time
  time.hardwareClockInLocalTime = true;

  # Don't change ever
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";
}
