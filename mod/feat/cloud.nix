# Cloud CLIs and secrets
{
  flake.modules.homeManager.cloud = { pkgs, ... }: {
    home.packages = with pkgs; [
      awscli2
      oci-cli
      vault
    ];
  };
}
