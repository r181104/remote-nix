{
  config,
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
    ./modules/fastapi.nix
    ./modules/wireguard.nix
  ];

  networking.hostName = "remote-nix";
  environment.systemPackages = with pkgs; [
    curl
    git
    openssl
    qrencode
    wireguard-tools
    unstable.neovim
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 2d";
  nix.optimise.automatic = true;
  nix.optimise.dates = "weekly";
  nix.settings.auto-optimise-store = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 8000];
    allowedUDPPorts = [51820];
    interfaces."wg0" = {
      allowedTCPPorts = [3000 53];
      allowedUDPPorts = [53];
    };
    trustedInterfaces = ["wg0"];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens5 -j MASQUERADE
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [
    "nix-command"
  ];
}
