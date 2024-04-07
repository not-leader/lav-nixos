{ config, lib, pkgs, userSettings, systemSettings, ... }:

{
  imports = [
    ../../app/terminal/alacritty.nix
    ../../app/terminal/kitty.nix
    ../../app/terminal/konsole.nix
    ../../app/terminal/yakuake.nix
    ];
  services.xserver.desktopManager.plasma5 = {}
    enable = true;
    plugins = [ ];
    settings = { };
    extraConfig = ''
      '';
    xwayland = { enable = true; };
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    alacritty
    kitty
    libsForQt5.konsole
    libsForQt5.yakuake
    #killall
    libsForQt5.polkit-kde-agent
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    pavucontrol
    ];

}
