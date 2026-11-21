# AI coding agents (tracked from unstable; they move fast)
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.unstable; [
    claude-code
    codex
    codex-acp
    pi-coding-agent
  ];
}
