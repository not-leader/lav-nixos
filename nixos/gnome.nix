{

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.dconf.enable = true; #fix for gtk theming under wayland

  # auto rotate
  hardware.sensor.iio.enable = true;

  # Extensions
    environment.systemPackages =
    (with pkgs; [
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
      gnomeExtensions.just-perfection
      pkgs.gradience
    ]);
 
   # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "lavender";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

} 