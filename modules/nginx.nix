{
  config,
  pkgs,
  ...
}: {
  services.nginx = {
    enable = true;

    virtualHosts."rishabhhaldiya.me" = {
      root = "/var/www/rishabhhaldiya.me";
    };

    virtualHosts."www.rishabhhaldiya.me" = {
      root = "/var/www/rishabhhaldiya.me";
    };

    virtualHosts."_" = {
      default = true;
      rejectSSL = true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "rishabhhaldiya.me@proton.me";
  };

  services.nginx.virtualHosts."rishabhhaldiya.me".enableACME = true;
  services.nginx.virtualHosts."rishabhhaldiya.me".forceSSL = true;

  services.nginx.virtualHosts."www.rishabhhaldiya.me".enableACME = true;
  services.nginx.virtualHosts."www.rishabhhaldiya.me".forceSSL = true;
}
