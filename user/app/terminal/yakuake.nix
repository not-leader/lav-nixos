{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    libsForQt5.yakuake
  ];
  programs.libsForQt5.yakuake.enable = true;
  programs.libsForQt5.yakuake.settings = {
    background_opacity = lib.mkForce "0.75";
  };
}
