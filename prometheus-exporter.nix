{ config, ...}:
{
  services.nebula.networks.mariusne.settings.firewall.inbound = [
    {
      port = "9558";
      proto = "any";
      host = "any";
    }
    {
      port = "9100";
      proto = "any";
      host = "any";
    }
  ];

  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
      listenAddress = config.marinfra.info.nebula_address;
    };
    systemd = {
      enable = true;
      listenAddress = config.marinfra.info.nebula_address;
      openFirewall = true;
      extraFlags = [
        "--systemd.collector.enable-ip-accounting"
      ];
    };
  };
  #TODO: nginx
}
