{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

	nix-ld = {
	 url = "github:Mic92/nix-ld";
	 inputs.nixpkgs.follows = "nixpkgs";
	};
	
     home-manager = {
       url = "github:nix-community/home-manager/release-23.11";
       inputs.nixpkgs.follows = "nixpkgs";
     };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/default/config.nix
         inputs.home-manager.nixosModules.default
      ];
    };
  };
}
