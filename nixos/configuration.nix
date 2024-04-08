# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  options,
  ...
}: let
  hostname = "i7-6950x"; # to alllow per-machine config
in {
  networking.hostName = hostname;

  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
     #inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    #./home-manager/home.nix
    #(~/Nix/nixos + "/${hostname}.nix")
  ]; 

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Bluetooth 
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

 # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.dconf.enable = true; #fix for gtk theming under wayland
  
  # Enables Wayland
  services.xserver.displayManager.defaultSession = "plasmawayland";

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Add the rest of your current configuration

  # systen d bootloader 
  #boot.loader.systemd-boot.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lavender = {
    isNormalUser = true;
    description = "Lavender";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      steam
      itch    
      keepassxc
      armcord
      gimp-with-plugins
      #gimp
      inkscape-with-extensions
      #gimpPlugins.resynthesizer
      krita
      github-desktop
      wineWowPackages.stable
      winetricks
      syncthing
      libresprite
      spotify
      handbrake
      slade
      trenchbroom
      easyeffects
      audacity
      prismlauncher
      mpv
      haruna 
      deluge
      vscodium
      godot_4
      lutris-free
      httrack
      kate
      libsForQt5.filelight
      obs-studio
      #thunderbird
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit config.nix! The Nano editor is also installed by default.
     wget
     micro
     htop
     neofetch
     python3
     vulkan-tools
     mesa-demos
     git
  ];

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  #services.openssh = {
    #enable = true;
    #settings = {
      # Forbid root login through SSH.
      #PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      #PasswordAuthentication = false;
    #};
  #};

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
