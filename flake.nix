{
  description = "My Flake";
    
  inputs = {
     nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11"; 
  };

  outputs = {nixpkgs, ...}: 
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "6950x"; # hostname
        profile = "personal"; # select a profile defined from my profiles directory
        timezone = "Europe/London"; # select timezone
        locale = "en_GB.UTF-8"; # select locale
        bootMode = "bios"; # uefi or bios
        bootMountPath = "/boot"; # mount path for efi boot partition; only used for uefi boot mode
        grubDevice = "/dev/nvme0n1"; # device identifier for grub; only used for legacy (bios) boot mode
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "lavender"; # username
        name = "Lavender"; # name/identifier
        email = "misslav@protonmail.com"; # email (used for certain configurations)
        dotfilesDir = "~/.nixos-config"; # absolute path of the local repo
        theme = "uwunicorn-yt"; # selcted theme from my themes directory (./themes/)
        desktop = "plasma"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
        browser = "firefox"; # Default browser; must select one from ./user/app/browser/
        term = "konsole"; # Default terminal command;
        font = "fira-go"; # Selected font
        fontPkg = pkgs.fira-go; # Font package
        editor = "micro"; # Default editor;

      };

      supportedSystems = [ "systemSettings.system" ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;


  in {
    templates = {
      minimal = {
        description = ''
          Minimal flake - contains only the configs.
          Contains the bare minimum to migrate your existing legacy configs to flakes.
        '';
        path = ./minimal;
      };
      standard = {
        description = ''
          Standard flake - augmented with boilerplate for custom packages, overlays, and reusable modules.
          Perfect migration path for when you want to dive a little deeper.
        '';
        path = ./standard;
      };
    };
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
}
