{
  config,
  pkgs,
  ...
}: {
  services.nginx = {
    enable = true;

    virtualHosts."rishabhhaldiya.me" = {
      root = "/var/www/rishabhhaldiya.me";

      addSSL = true;

      sslCertificate = "/etc/ssl/cloudflare/cert.pem";
      sslCertificateKey = "/etc/ssl/cloudflare/key.pem";
      sslTrustedCertificate = "/etc/ssl/cloudflare/cert.pem";

      locations."/" = {
        index = "index.html";
      };
    };

    virtualHosts."www.rishabhhaldiya.me" = {
      root = "/var/www/rishabhhaldiya.me";

      addSSL = true;

      sslCertificate = "/etc/ssl/cloudflare/cert.pem";
      sslCertificateKey = "/etc/ssl/cloudflare/key.pem";
      sslTrustedCertificate = "/etc/ssl/cloudflare/cert.pem";
    };
  };
}
