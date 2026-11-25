# Spotifast (Spotify client). It downloads Spotify Soloist, a generic binary run
# through nix-ld, which inherits Spotifast's LD_LIBRARY_PATH. Those libraries
# come from unstable, so nix-ld must load Soloist with unstable's glibc as well:
# with the stable loader libpulse fails to load and every track instantly pauses.
{
  flake.modules.nixos.spotifast = {
    programs.nix-ld.enable = true;

    # Open spotify: links here rather than in the official client. System-wide:
    # home-manager would make ~/.config/mimeapps.list read-only.
    xdg.mime.defaultApplications."x-scheme-handler/spotify" = "spotifast.desktop";
  };

  flake.modules.homeManager.spotifast =
    { pkgs, ... }:
    let
      inherit (pkgs.unstable)
        lib
        makeWrapper
        spotifast
        stdenv
        symlinkJoin
        ;
    in
    {
      home.packages = [
        (symlinkJoin {
          name = "spotifast-${spotifast.version}";
          paths = [ spotifast ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/spotifast \
              --set NIX_LD ${stdenv.cc.bintools.dynamicLinker} \
              --set NIX_LD_LIBRARY_PATH ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}
          '';
        })
      ];
    };
}
