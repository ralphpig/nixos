# nixos

My NixOS machine(s) and home-manager config in one flake, in the dendritic
pattern: every `.nix` file under `mod/` is a flake-parts module, loaded
automatically by import-tree (except paths starting with `_`).

## Layout

```
flake.nix                    # inputs, and import-tree ./mod
mod/
  host/<hostname>/           # one per machine: hardware, and which features it uses
    _hardware-configuration.nix  # generated only (--no-filesystems), never hand-edited
    _storage.nix             #   hand-written: filesystems, swap, ZFS
  user/<name>.nix            # one per user: account, and which features it uses
  feat/                      # independent features: desktops, apps, dev tools
  sys/                       # core system, on every host (`base`)
    boot.nix                 #   grub, plymouth, silent boot; opt-in (`boot`), not in base
    home-manager.nix         #   the only home-manager plumbing
    shell/                   #   zsh, git, neovim: every user, root included
wallpapers/
```

## Features

A feature has a system half, a home half, or both:

```nix
{
  flake.modules.nixos.foo = { pkgs, ... }: { };       # system; imported by hosts
  flake.modules.homeManager.foo = { pkgs, ... }: { }; # home; imported by users
}
```

- A feature with both must be listed in both the host and the user.
- Packages go in the home half (`home.packages`). Tools everyone needs go in
  `sys/util.nix`.
- Importing is enabling; there are no `enable` options.
- Features don't import other features (`flake.modules` doesn't deduplicate)
  and don't name users.
- `sys/` adds to `nixos.base` / `homeManager.base`, except `boot`, which a host
  imports and overrides.
- Stylix is optional: what a feature sets for it is guarded by
  `options ? stylix`.

`pkgs.unstable.<name>` gives a package from nixpkgs-unstable.

## Daily use

The repo lives at `~/nixos` (`programs.nh.flake` points there).

```sh
nh os switch          # build + activate system and home config
nh os switch --update # same, after updating flake.lock
nh os build           # build only, shows a package diff
nix flake update      # bump inputs (then switch)
```

System and home-manager config are applied together. There is no separate
`home-manager switch`.

App configs in a feature's `config/` are symlinked live into this repo, so
changing settings in zed/sublime edits these files directly. Commit them like any
other change.

Pick the boot desktop with `defaultSession` in the host, or any of them at the
login screen. Optional features (`ollama` in the host, `llama-cpp-prism` in the
user) are commented out there.

## Fresh install

From the NixOS installer, after partitioning, creating the ZFS pool/datasets
(see `mod/host/<hostname>/_storage.nix`) and mounting everything under `/mnt`:

```sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nixos-generate-config --root /mnt --show-hardware-config --no-filesystems \
  > /tmp/_hardware-configuration.nix

git clone https://github.com/ralphpig/nixos /mnt/home/ralphpig/nixos   # https: no ssh keys yet
cp /tmp/_hardware-configuration.nix /mnt/home/ralphpig/nixos/mod/host/<hostname>/
# new machine: copy an existing mod/host/ folder, then adjust _storage.nix, hostname,
# and networking.hostId (head -c4 /dev/urandom | od -A none -t x4)

nixos-install --flake /mnt/home/ralphpig/nixos#<hostname>
nixos-enter --root /mnt -c 'passwd ralphpig'
```

After first boot:

```sh
sudo chown -R ralphpig:users ~/nixos
cd ~/nixos && git remote set-url origin git@github.com:ralphpig/nixos.git
```

Reinstalling an existing host can skip regenerating the hardware config.
The `~/.config` symlinks to `mod/feat/*/config` resolve once the repo is at `~/nixos`.
