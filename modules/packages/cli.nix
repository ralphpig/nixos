# Everyday command-line tools. git, neovim and zsh are installed and
# configured per user by home-manager (home/common).
{ pkgs, ... }:
{
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

    # SOPS
    age
    sops
    ssh-to-age

    # Ghostty (home/ghostty.nix) sets TERM=xterm-ghostty; install its terminfo
    # system-wide so other users (`su -`, `sudo -i`, root) can find it.
    ghostty.terminfo
  ];
}
