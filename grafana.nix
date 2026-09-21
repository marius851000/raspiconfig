{ config, ... }:

{
  services.nebula.networks.mariusne.settings.firewall.inbound = [
    {
      port = builtins.toString config.services.grafana.settings.server.http_port;
      proto = "any";
      host = "any";
    }
  ];

  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 2345;
      http_addr = config.marinfra.info.nebula_address;
      root_url = "https://%(domain)s:%(http_port)s/eespie";
    };
    /*settings.smtp = rec {
      user = "grafana@mariusdavid.fr";
      fromAddress = user;
      host = "mariusdavid.fr:465";
      enabled = true;
      passwordFile = "/secret-mail-grafana.txt";
      };*/
    settings.security = {
      # actually not a secret. This is fine. Only used to encrypt files that are already protected by permission.
      secret_key = "SW2YcwTIb9zpOOhoPsMm";
    };
    provision.datasources.settings.datasources = [
      {
        name = "prometheus-local";
        type = "prometheus";
        access = "proxy";
        url = "http://${config.marinfra.info.all_machines.zana.options.marinfra.info.nebula_address.value}:9090";
      }
    ];
  };
}
