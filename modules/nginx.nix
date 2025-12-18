{
  config,
  pkgs,
  ...
}: {
  services.nginx = {
    enable = true;

    virtualHosts."rishabhhaldiya.me" = {
      default = true;
      root = "/var/www/rishabhhaldiya.me";
      locations."/" = {
        index = "index.html";
      };
    };

    virtualHosts."www.rishabhhaldiya.me" = {
      root = "/var/www/rishabhhaldiya.me";
    };
  };
}
