#!/usr/bin/env bash
sudo nixos-rebuild switch --option eval-cache false --flake .#WorkStation &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)
