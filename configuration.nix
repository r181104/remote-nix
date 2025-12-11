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
  users.users.root = {
    hashedPassword = "$argon2id$v=19$m=65536,t=2,p=4$/yLJF3JRInJF2OHUE86yOQ$btwO7dBwVUPSjTc4/OG57KyYiLAsTdI8HlXdeyez22I";
  };
  users.users.sten = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = ["wheel"];
    description = "sten";
    hashedPassword = "$argon2id$v=19$m=65536,t=2,p=4$/yLJF3JRInJF2OHUE86yOQ$btwO7dBwVUPSjTc4/OG57KyYiLAsTdI8HlXdeyez22I";
  };

  environment.shells = with pkgs; [bash];
  environment.systemPackages = with pkgs; [
    curl
    git
    unstable.neovim
  ];

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  systemd.tmpfiles.rules = ["d /swap 0755 root root -"];
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 4096;
    }
  ];
  system.stateVersion = "25.11";
}
