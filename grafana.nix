{ ... }:

{
  services.nginx = {
    virtualHosts."mariusdavid.fr" = {
      locations = {
        "/eespie/" = {
          proxyPass = "http://localhost:2345/";
          extraConfig = ''
            access_log off;
          '';
        };
      };
    };
  };

  services.grafana = {
    addr = "0.0.0.0";
    enable = true;
    port = 2345;
    rootUrl = "https://%(domain)s:%(http_port)s/eespie";
    settings.smtp = rec {
      user = "grafana@mariusdavid.fr";
      fromAddress = user;
      host = "mariusdavid.fr:587";
      enable = true;
      passwordFile = "/secret-mail-grafana.txt";
    };
    provision.datasources.settings.datasources = [
      {
        name = "prometheus-local";
        type = "prometheus";
        access = "proxy";
        url = "http://localhost:9090";
      }
    ];
  };
}