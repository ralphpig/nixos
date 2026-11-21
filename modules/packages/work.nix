# Work: cloud CLIs, k8s, databases
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    awscli2
    glab
    husky
    insomnia
    kubectl
    kubeseal
    mongodb-tools
    unstable.mongodb-compass
    oci-cli
    pgcli
    postgresql
    vault
  ];
}
