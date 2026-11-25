# Command-line tools for every user, root included
{
  flake.modules.nixos.base = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      bind
      htop
      jq
      lsof
      ncdu
      osv-scanner
      ripgrep
      wget
      wl-clipboard
    ];
  };
}
