# Kubernetes
{
  flake.modules.homeManager.k8s = { pkgs, ... }: {
    home.packages = with pkgs; [
      kubectl
      kubeseal
    ];
  };
}
