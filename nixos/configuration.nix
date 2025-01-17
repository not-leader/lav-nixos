# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # You can also split up your config and import pieces of it here:
    ./plasma.nix
    ./locale.nix
    ./system.nix
    #./virtualbox.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager

    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-intel-cpu-only
    #inputs.hardware.nixosModules.common-gpu-amd
    #inputs.hardware.nixosModules.common-ssd
  ];

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
      allowInsecure = true;
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

  # Set your hostname
  networking.hostName = "WorkStation";

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    lavender = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;

      # Be sure to add any other groups you need
      # (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager"];
      packages = with pkgs; [
        firefox-unwrapped
        floorp
        itch
        prismlauncher
        r2modman
        keepassxc
        gimp-with-plugins
        blender-hip
        #gimp
        plasticity
        inkscape-with-extensions
        krita
        github-desktop
        wineWowPackages.stable
        winetricks
        syncthing
        libresprite
        spotify
        handbrake
        #slade
        trenchbroom
        easyeffects
        audacity
        mpv
        haruna
        deluge
        vscodium
        godot_4
        lutris-free
        httrack
        kate
        p7zip
        libsForQt5.filelight
        obs-studio
        alejandra
        zulu #java4minecraft
        pwvucontrol
        moonlight-qt
        #quake related
        vkquake
        ironwail
        quakespasm
        darkplaces
        fteqw
        fteqcc
        embree
        embree2
        ericw-tools
        trenchbroom
        qpakman
      ];

      #openssh.authorizedKeys.keys = [
      # Add your SSH public key(s) here, if you plan on using SSH to connect
      #];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # for r2modman 3.1.44
    "freeimage-unstable-2021-11-01"
    #"python-2.7.18.7"
  ];

  #nixpkgs.config.allowBroken = true;

  # systemd bootloader
  #boot.loader.systemd-boot.enable = true;

  # grub bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit config.nix! The Nano editor is also installed by default.
    wget
    micro
    bash
    git
    htop
    neofetch
    python3
    vulkan-tools
    mesa-demos
    flatpak
    libsForQt5.yakuake
    libsForQt5.discover
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [47984 47989 47990 48010];
    allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48000;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.steam.gamescopeSession.enable = true; # set steam to start in gamescope

  boot.kernelPackages = pkgs.linuxPackages_latest;

  #flatpak supports
  services.flatpak.enable = true;

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     # Forbid root login through SSH.
  #     PermitRootLogin = "no";
  #     # Use keys only. Remove if you want to SSH using password (not recommended)
  #     PasswordAuthentication = false;
  #   };
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
