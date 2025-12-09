{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  pkgs = import (fetchTarball {
    url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
  }) {};
  unstable = import (fetchTarball {
    url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  }) {};
in {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    # My custom modules
    ./modules/base.nix
    ./modules/wireguard.nix
    ./modules/development.nix
  ];

  networking.hostName = "remote-nix";
  users.users.sten = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = ["wheel"];
    description = "sten";
  };

  environment.shells = with pkgs; [bash];
  environment.systemPackages = with pkgs; [
    curl
    git
    unstable.neovim
  ];

  systemd.tmpfiles.rules = ["d /var/swap 0755 root root -"];
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      size = 4096;
    }
  ];

  system.stateVersion = "25.11";
}
