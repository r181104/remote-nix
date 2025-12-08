{
  description = "Hybrid NixOS flake with stable base and selected unstable packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: let
    system = "x86_64-linux";
    env = let
      hostname = "remote-nix";
      domain = "local";
      fqdn = "${hostname}.${domain}";
    in {inherit username hostname domain fqdn;};
  in {
    nixosConfigurations.${env.hostname} = nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = {
        inherit env;
      };
      modules = [
        ./configuration.nix

        ({pkgs, ...}: {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = nixpkgs-unstable.legacyPackages.${system};
            })
          ];

          environment.systemPackages = with pkgs; [
            unstable.neovim
          ];
        })
      ];
    };
  };
}
