{

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.dconf.enable = true; #fix for gtk theming under wayland
  
  # Enables Wayland
  services.xserver.displayManager.defaultSession = "plasmawayland";
  
}