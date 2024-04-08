{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #Add any other flake you might need

    # hardware flakes
    hardware.url = "github:nixos/nixos-hardware";
    
    # Run unpatched dynamic binaries 
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    #theme-ing
    stylix.url = "github:danth/stylix";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-ld,
    nixos-hardware,
    stylix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    
      # # ---- SYSTEM SETTINGS ---- #
      # systemSettings = {
      #   system = "x86_64-linux"; # system arch
      #   hostname = "6950x"; # hostname
      #   profile = "personal"; # select a profile defined from my profiles directory
      #   timezone = "Europe/London"; # select timezone
      #   locale = "en_GB.UTF-8"; # select locale
      #   bootMode = "bios"; # uefi or bios
      #   bootMountPath = "/boot"; # uefi only; mount path for efi boot partition
      #   grubDevice = "/dev/nvme0n1"; # legacy (bios) only; device identifier for grub
      # };  

    # # ----- USER SETTINGS ----- #
    # userSettings = rec {
    #   username = "lavender"; # username
    #   name = "Lavender"; # name/identifier
    #   email = "misslav@protonmail.com"; # email (used for certain configurations)
    #   #dotfilesDir = "~/Nix"; # absolute path of the local repo
    #   #theme = "uwunicorn-yt"; # selcted theme from my themes directory (./themes/)
    #   #desktop = "plasma"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
    #   #browser = "firefox"; # Default browser; must select one from ./user/app/browser/
    #   term = "konsole"; # Default terminal command;
    #   font = "fira-go"; # Selected font
    #   #fontPkg = pkgs.fira-go; # Font package
    #   editor = "micro"; # Default editor;

    # };
    
    
    # Supported systems for your flake packages, shell, etc.
    supportedSystems = [
      "x86_64-linux"
      #"aarch64-linux"
      "i686-linux"
      #"x86_64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#6950x'

    nixosConfigurations = {
      # hostname
      i7-6950x = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
          nixos-hardware.nixosModules.common-cpu-intel-cpu-only
          nixos-hardware.nixosModules.common-gpu-amd

          # ... add this line to the rest of your configuration modules
          nix-ld.nixosModules.nix-ld
          { programs.nix-ld.dev.enable = true; }

        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # lavender@i7-6950x
      "lavender@i7-6950x" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [./home-manager/home.nix];
      };
    };
  };
}
