#!/bin/sh

# Automated script to install my dotfiles

# Clone dotfiles
nix-shell -p git --command "git clone https://github.com/MissLavender-LQ/nixos-config ~/.nixos-config"

nix-shell -p micro

# Generate hardware config for new system
sudo nixos-generate-config --show-hardware-config > ~/.nixos-config/system/hardware-configuration.nix

# Check if uefi or bios
if [ -d /sys/firmware/efi/efivars ]; then
    sed -i "0,/bootMode.*=.*\".*\";/s//bootMode = \"uefi\";/" ~/.nixos-config/flake.nix
else
    sed -i "0,/bootMode.*=.*\".*\";/s//bootMode = \"bios\";/" ~/.nixos-config/flake.nix
    grubDevice=$(findmnt / | awk -F' ' '{ print $2 }' | sed 's/\[.*\]//g' | tail -n 1 | lsblk -no pkname | tail -n 1 )
    sed -i "0,/grubDevice.*=.*\".*\";/s//grubDevice = \"\/dev\/$grubDevice\";/" ~/.nixos-config/flake.nix
fi

# Patch flake.nix with different username/name and remove email by default
sed -i "0,/lavender/s//$(whoami)/" ~/.nixos-config/flake.nix
sed -i "0,/Lavender/s//$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1)/" ~/.nixos-config/flake.nix
sed -i "s/misslav@protonmail.com//" ~/.nixos-config/flake.nix

# Open up editor to manually edit flake.nix before install
if [ -z "$EDITOR" ]; then
    EDITOR=micro;
fi
$EDITOR ~/.nixos-config/flake.nix;

# Permissions for files that should be owned by root
sudo ~/.nixos-config/harden.sh ~/.nixos-config;

# Rebuild system
sudo nixos-rebuild switch --flake ~/.nixos-config#system;

# Install and build home-manager configuration
nix run home-manager/master --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.nixos-config#user;

