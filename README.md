# NixOS System Configuration

This is my NixOS system flake configuration.
I use [nh (nix helper)](https://github.com/nix-community/nh).
If you want to use this configuration from a fresh install run: `sudo nixos-install --flake github:diego-velez/nixos#[desktop|laptop] --extra-experimental-features "nix-command flakes"`
If you want to create a new generation with this flake already installed, run: `nh os boot . -H [desktop|laptop]`.

> [!Note]
> I have to setup my machines with disko for easier installation with nixos-anywhere.
> I already have a btrfs disko config for my desktop host, I just need to migrate my machine.
> See [setting_up_disko_after_installation](https://www.reddit.com/r/NixOS/comments/1tc50pu/setting_up_disko_after_installation).
