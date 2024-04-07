{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    libsForQt5.konsole
  ];
  programs.libsForQt5.konsole.enable = true;
  programs.libsForQt5.konsole.settings = {
    background_opacity = lib.mkForce "0.75";
  };
}
