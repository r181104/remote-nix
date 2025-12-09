{
  config,
  pkgs,
  ...
}: {
  services.amazon-ssm-agent.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      AuthenticationMethods = "publickey";
      MaxAuthTries = 3;
      LoginGraceTime = "30s";
      AllowTcpForwarding = false;
      X11Forwarding = false;
    };
  };
  services.fail2ban = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    openssl
    qrencode
    wireguard-tools
  ];

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 2d";
  nix.optimise.automatic = true;
  nix.optimise.dates = "weekly";
  nix.settings.auto-optimise-store = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8000];
    allowedUDPPorts = [51820];
    interfaces."wg0" = {
      allowedTCPPorts = [22 3000 53];
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

  boot.kernel.sysctl."vm.swappiness" = 10;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  system.stateVersion = "25.11";
  nix.settings.experimental-features = [
    "nix-command"
  ];
}
