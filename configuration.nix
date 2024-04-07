{
  config,
  pkgs,
  options,
  ...
}: let
  system = "x86_64-linux"; # system arch
  hostname = "oatman-pc"; # to alllow per-machine config
  timezone = "Europe/London"; # select timezone
  locale = "en_GB.UTF-8"; # select locale
  bootMode = "bios"; # uefi or bios
  bootMountPath = "/boot"; # uefi only; mount path for efi boot partition
in {
  networking.hostName = hostname;

  imports = [
    /etc/nixos/hardware-configuration.nix
    (~/nix/ + "/${hostname}.nix")
  ];
}
