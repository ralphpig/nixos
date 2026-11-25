# Declares `flake.modules.<class>.<name>`, which every file here adds to.
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
