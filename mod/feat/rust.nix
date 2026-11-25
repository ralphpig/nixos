# Rust toolchain and the native libraries its crates build against
{
  flake.modules.homeManager.rust = { pkgs, ... }: {
    home.packages = with pkgs; [
      gcc
      just
      rustup
      sqlx-cli
      pkg-config
      lcms2
      nasm
      openssl.dev
    ];

    # Allow rustc to find openssl
    home.sessionVariables.PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
