# nixos

My NixOS machine(s) and home-manager config in one flake.

## Layout

```
flake.nix                    # inputs (nixpkgs 26.05, nixpkgs-unstable, home-manager) + hosts
hosts/<hostname>/            # one folder per machine
  default.nix                #   imports, hostname, stateVersion, which desktop/modules
  hardware-configuration.nix #   generated only (--no-filesystems), never hand-edited
  storage.nix                #   hand-written: filesystems, swap, ZFS
  boot.nix                   #   grub, plymouth, silent boot
modules/                     # reusable NixOS modules
  core.nix                   #   nix/nixpkgs settings, nh, locale, networking, user
  home-manager.nix           #   wires home-manager in (main user + root)
  services.nix  fonts.nix
  packages/{cli,dev,ai,work,apps}.nix
  llm/                       #   opt-in: ollama + open-webui, llama.cpp fork
desktop/<name>/              # one folder per desktop environment
  nixos.nix                  #   system side; also imports ./home.nix for the user
  home.nix                   #   user side (dconf etc.); usable standalone
desktop/dux-shell/           # the shell shared by hyprland and niri; imported by their nixos.nix
home/
  common/                    # portable zsh/git/neovim, applied to the user AND root
  dotfiles.nix               # live symlinks: ~/.config/<app> -> ~/nixos/home/config/<app>
  config/                    # app configs edited in place (zed, sublime, sql-formatter)
  ralphpig.nix  root.nix     # per-user entry points
wallpapers/                  # referenced live from the checkout (my.repoDir)
```

The username is defined once in `flake.nix` and passed to modules as `username`.
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

App configs under `home/config/` are symlinked live into this repo, so changing
settings in zed/sublime edits these files directly. Commit them like any other change.

## Switching desktops

Pick the desktop in `hosts/<hostname>/default.nix`:

```nix
../../desktop/gnome/nixos.nix
# ../../desktop/hyprland/nixos.nix
# ../../desktop/niri/nixos.nix
```

A new desktop is a new `desktop/<name>/` folder with a `nixos.nix` (system side,
importing its `home.nix` via `home-manager.users.${username}.imports`) and a
`home.nix` (user side). Two desktops can be enabled at once and chosen at the login screen.

## Optional modules

Uncomment in the host's `default.nix`:

- `modules/llm/ollama.nix`: ollama (ROCm) + Open WebUI on http://localhost:10000
- `modules/llm/llama-cpp-prism.nix`: PrismML llama.cpp fork (ternary GGUF types)

## Fresh install

From the NixOS installer, after partitioning, creating the ZFS pool/datasets
(see `hosts/<hostname>/storage.nix`) and mounting everything under `/mnt`:

```sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nixos-generate-config --root /mnt --show-hardware-config --no-filesystems \
  > /tmp/hardware-configuration.nix

git clone https://github.com/ralphpig/nixos /mnt/home/ralphpig/nixos   # https: no ssh keys yet
cp /tmp/hardware-configuration.nix /mnt/home/ralphpig/nixos/hosts/<hostname>/
# new machine: copy an existing hosts/ folder, then adjust storage.nix, hostname,
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
The `~/.config` symlinks in `home/dotfiles.nix` resolve once the repo is at `~/nixos`.

## Non-NixOS

`home/common` and `desktop/*/home.nix` don't depend on NixOS. To use them with
standalone home-manager, add a `homeConfigurations."ralphpig@<host>"` output to
`flake.nix` that imports `home/common`, `home/dotfiles.nix` and any desktop
`home.nix`, setting `home.username`/`home.homeDirectory` there.
