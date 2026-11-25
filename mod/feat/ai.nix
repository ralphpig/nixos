# AI coding agents (tracked from unstable; they move fast)
{
  flake.modules.homeManager.ai = { pkgs, ... }: {
    home.packages = with pkgs.unstable; [
      claude-code
      codex
      codex-acp
      pi-coding-agent
    ];
  };
}
