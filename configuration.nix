{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];
  networking.hostName = "remote-nix";

  environment.systemPackages = with pkgs; [
    neovim
    curl
    git
    openssl
    qrencode
    wireguard-tools
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [22];
    allowedUDPPorts = [51820];
    interfaces."wg0" = {
      allowedTCPPorts = [3000 53];
      allowedUDPPorts = [53];
    };
    trustedInterfaces = ["wg0"];
    firewall.extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens5 -j MASQUERADE
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens5";
    internalInterfaces = ["wg0"];
  };
  networking.wireguard.interfaces."wg0" = {
    ips = ["10.8.0.1/24"];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/server.key";

    peers = [
      {
        # Laptop
        publicKey = "b3Ujc0svlDZHqypecZMziIYTdG3ECzgamAqnV+Fshjc=";
        allowedIPs = ["10.8.0.2/32"];
      }
      {
        # Phone
        publicKey = "P1xY9TkGgB5ZPBMmHKAcQ5lokdycZgOieIC5KiHCUjc=";
        allowedIPs = ["10.8.0.3/32"];
      }
    ];
  };

  services.adguardhome = {
    enable = true;
    openFirewall = false;
    mutableSettings = true;
    host = "10.8.0.1";
    port = 3000;

    settings = {
      dns = {
        bind_host = "10.8.0.1";
        port = 53;

        upstream_dns = [
          "https://1.1.1.1/dns-query"
          "https://1.0.0.1/dns-query"
        ];
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };
    };
  };

  system.stateVersion = "25.11";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
