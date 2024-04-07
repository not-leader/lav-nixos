{
  description = "Lavender's Flake";
  
  outputs = inputs@{ self, pkgs, nixpkgs, nixpkgs-stable, home-manager-unstable, 
                     home-manager, stylix, ... }:
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


      # create patched nixpkgs
      nixpkgs-patched =
        (import nixpkgs { system = systemSettings.system; }).applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs;
          patches = [ ./patches/placeholder.patch ];
        };

      # configure pkgs
      # use nixpkgs if running a server (homelab or worklab profile)
      # otherwise use patched nixos-unstable nixpkgs
      pkgs = (if ((systemSettings.profile == "personal") || (systemSettings.profile == "server"))
              then
                pkgs-stable
              else
                (import nixpkgs-patched {
                  system = systemSettings.system;
                  config = {
                    allowUnfree = true;
                    allowUnfreePredicate = (_: true);
                  };
                }));

      pkgs-stable = import nixpkgs-stable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };


      # configure lib
      # use nixpkgs if running a server (homelab or worklab profile)
      # otherwise use patched nixos-unstable nixpkgs
      lib = (if ((systemSettings.profile == "personal") || (systemSettings.profile == "server"))
             then
               nixpkgs-stable.lib
             else
               nixpkgs.lib);

      # use home-manager if running a server (homelab or worklab profile)
      # otherwise use home-manager-unstable
      home-manager = (if ((systemSettings.profile == "personal") || (systemSettings.profile == "server"))
             then
               home-manager
             else
               home-manager-unstable);

      # Systems that can run tests:
      supportedSystems = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });

    in {
      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile)
              + "/home.nix") # load home.nix from selected PROFILE
              inputs.nix-flatpak.homeManagerModules.nix-flatpak # Declarative flatpaks
          ];
          extraSpecialArgs = {
            # pass config variables from above
            inherit pkgs-stable;
            # inherit pkgs-emacs;
            # inherit pkgs-kdenlive;
            inherit systemSettings;
            inherit userSettings;
            # inherit (inputs) nix-doom-emacs;
            # inherit (inputs) org-nursery;
            # inherit (inputs) org-yaap;
            # inherit (inputs) org-side-tree;
            # inherit (inputs) org-timeblock;
            # inherit (inputs) org-krita;
            # inherit (inputs) phscroll;
            # inherit (inputs) mini-frame;
            inherit (inputs) nix-flatpak;
            inherit (inputs) stylix;
          };
        };
      };
      # nixosConfigurations = {
      #   system = lib.nixosSystem {
      #     system = systemSettings.system;
      #     modules = [
      #       (./. + "/profiles" + ("/" + systemSettings.profile)
      #         + "/configuration.nix")
      #     ]; # load configuration.nix from selected PROFILE
      #     specialArgs = {
      #       # pass config variables from above
      #       inherit pkgs-stable;
      #       inherit systemSettings;
      #       inherit userSettings;
      #       inherit (inputs) stylix;
      #       # inherit (inputs) blocklist-hosts;
      #     };  
      #   };
      # };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = self.packages.${system}.install;

          install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = with pkgs; [ git ]; # I could make this fancier by adding other deps
            text = ''${./install.sh} "$@"'';
          };
        });

      apps = forAllSystems (system: {
        default = self.apps.${system}.install;

        install = {
          type = "app";
          program = "${self.packages.${system}.install}/bin/install";
        };
      });
    };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-23.11";
    # emacs-pin-nixpkgs.url = "nixpkgs/f72123158996b8d4449de481897d855bc47c7bf6";
    # kdenlive-pin-nixpkgs.url = "nixpkgs/cfec6d9203a461d9d698d8a60ef003cac6d0da94";

    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    
    #plasma-manager.url = "github:pjones/plasma-manager";
    #plasma-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    #inputs.home-manager.follows = "home-manager";

    # nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # nix-doom-emacs.inputs.nixpkgs.follows = "emacs-pin-nixpkgs";

    # nix-straight.url = "github:librephoenix/nix-straight.el/pgtk-patch";
    # nix-straight.flake = false;
    # nix-doom-emacs.inputs.nix-straight.follows = "nix-straight";

    # eaf = {
    #   url = "github:emacs-eaf/emacs-application-framework";
    #   flake = false;
    # };
    # eaf-browser = {
    #   url = "github:emacs-eaf/eaf-browser";
    #   flake = false;
    # };
    # org-nursery = {
    #   url = "github:chrisbarrett/nursery";
    #   flake = false;
    # };
    # org-yaap = {
    #   url = "gitlab:tygrdev/org-yaap";
    #   flake = false;
    # };
    # org-side-tree = {
    #   url = "github:localauthor/org-side-tree";
    #   flake = false;
    # };
    # org-timeblock = {
    #   url = "github:ichernyshovvv/org-timeblock";
    #   flake = false;
    # };
    # org-krita = {
    #   url = "github:lepisma/org-krita";
    #   flake = false;
    # };
    # phscroll = {
    #   url = "github:misohena/phscroll";
    #   flake = false;
    # };
    # mini-frame = {
    #   url = "github:muffinmad/emacs-mini-frame";
    #   flake = false;
    # };

    stylix.url = "github:danth/stylix";

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [

    # Add any missing dynamic libraries for unpackaged programs

    # here, NOT in environment.systemPackages

  ];

    # rust-overlay.url = "github:oxalica/rust-overlay";

    # blocklist-hosts = {
    #   url = "github:StevenBlack/hosts";
    #   flake = false;
    # };
    
  };
}
