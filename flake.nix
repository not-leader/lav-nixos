{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #Add any other flake you might need
    hardware.url = "github:nixos/nixos-hardware";
    qpakman.url = "github:not-leader/nixpkgs/add-qpakman";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixpkgs-unstable,
    qpakman,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    # systems = [
    #   "aarch64-linux"
    #   "i686-linux"
    #   "x86_64-linux"
    # ];

    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    #forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    #packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = nixpkgs.lib.genAttrs (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#WorkStation'
    nixosConfigurations = {
      WorkStation = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          inherit pkgs-unstable;
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#lavender@WorkStation'
    #homeConfigurations = {
    # username@hostname
    # "lavender@WorkStation" = home-manager.lib.homeManagerConfiguration {
    #  pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
    # extraSpecialArgs = {inherit inputs outputs;};
    #modules = [
    # > Our main home-manager configuration file <
    # ./home-manager/home.nix
    #];
    #};
    #};
  };
}
