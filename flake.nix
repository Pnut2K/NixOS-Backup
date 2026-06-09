# flake.nix
{
  description = "My configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # IMPORTANT
    nix-mineral.url = "github:cynicsketch/nix-mineral/"; # Refers to the main branch and is updated to the latest commit when you use "nix flake update"
  };

  outputs = { nixpkgs, chaotic, ... }: {
    nixosConfigurations = {
      NixOS = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
	specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default # IMPORTANT
        ];
      };
    };
  };
}
