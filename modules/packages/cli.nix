# Everyday command-line tools
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    home-manager # TODO: drop once home-manager is a NixOS module

    bind
    git
    htop
    jq
    lsof
    ncdu
    neovim
    oh-my-zsh
    osv-scanner
    ripgrep
    wget
    wl-clipboard
    zsh

    # SOPS
    age
    sops
    ssh-to-age
  ];
}
