{
  config,
  pkgs,
  ...
}: {
  services.amazon-ssm-agent.enable = true;
  services.fail2ban = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    openssl
    qrencode
  ];

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 2d";
  nix.optimise.automatic = true;
  nix.optimise.dates = "weekly";
  nix.settings.auto-optimise-store = true;

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [53 80 443];
    allowedTCPPorts = [53 80 443];
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

  nix.settings.experimental-features = [
    "nix-command"
  ];
}
