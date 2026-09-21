{ config, ... }:

{
  services.nebula.networks.mariusne.settings.firewall.inbound = [
    {
      port = "9113";
      proto = "any";
      host = "any";
    }
  ];

  services.prometheus.exporters.nginx = {
    enable = true;
    listenAddress = config.marinfra.info.nebula_address;
    openFirewall = true;

  };
}
