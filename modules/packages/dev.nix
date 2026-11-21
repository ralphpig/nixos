# Editors, language toolchains, LSPs/formatters
{ pkgs, ... }:
{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for sublime4
  ];

  environment.systemPackages = with pkgs; [
    # Editors
    unstable.sublime-merge-dev
    sublime4
    zed-editor

    # JS / Java
    deno
    eslint
    jre
    nodejs_22
    pnpm_12
    yarn

    # Rust
    gcc
    just
    rustup
    sqlx-cli
    pkg-config
    lcms2
    nasm
    openssl.dev

    # LSP / formatters
    color-lsp
    nil
    nixd
    pgformatter
    shfmt
    sql-formatter
    yamlfmt
  ];

  # Allow rustc to find openssl
  environment.sessionVariables.PKG_CONFIG_PATH = [ "${pkgs.openssl.dev}/lib/pkgconfig" ];
}
