# JavaScript / TypeScript
{
  flake.modules.homeManager.js = { pkgs, ... }: {
    home.packages = with pkgs; [
      deno
      eslint
      husky
      nodejs_22
      pnpm_12
      yarn
    ];
  };
}
