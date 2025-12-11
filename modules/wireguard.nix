{
  config,
  pkgs,
  ...
}: {
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
}
