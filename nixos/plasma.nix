{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;

  services.desktopManager.plasma6.enable = true;
  programs.dconf.enable = true; #fix for gtk theming under wayland

  # Enables Wayland
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
}
