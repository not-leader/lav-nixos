# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "lavender";
    homeDirectory = "/home/lavender";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
   home.packages = with pkgs; [
      firefox
      itch    
      keepassxc
      armcord
      gimp-with-plugins
      blender-hip
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
    
  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
