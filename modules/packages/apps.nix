# Desktop applications (DE-agnostic)
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bitwarden-cli
    libreoffice
    microsoft-edge
    rapidraw
    spotify
    zoom-us
  ];
}
