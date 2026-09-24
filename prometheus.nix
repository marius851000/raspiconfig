{pkgs, config, lib, ...}:

let
  port = 9090;
in
{

  services.nebula.networks.mariusne.settings.firewall.inbound = [
    {
      port = builtins.toString port;
      proto = "any";
      host = "any";
    }
  ];

  services.prometheus = {
    enable = true;
    listenAddress = config.marinfra.info.nebula_address;
    retentionTime = "30d";
    exporters.blackbox = {
      enable = true;
      configFile = builtins.toFile "blackbox.yml" (lib.generators.toYAML { } {
        modules = {
          http_2xx = {
            prober = "http";
          };
        };
      });
    };
    scrapeConfigs = [
      {
        job_name = "systemd";
        scrape_interval = "30s";
        static_configs = [
          {
            targets = (builtins.map (x: "${x.value.options.marinfra.info.nebula_address.value}:9558") (lib.attrsToList config.marinfra.info.all_machines));
          }
        ];
      }
      {
        job_name = "nginx";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [ "${config.marinfra.info.all_machines.scrogne.options.marinfra.info.nebula_address.value}:9113" ];
          }
        ];
      }
      {
        job_name = "node";
        scrape_interval = "30s";
        static_configs = [
          {
            targets = (builtins.map (x: "${x.value.options.marinfra.info.nebula_address.value}:9100") (lib.attrsToList config.marinfra.info.all_machines));
          }
        ];
      }
      {
        job_name = "blackbox";
        scrape_interval = "30s";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [
          {
            targets = [ "https://mariusdavid.fr" "https://mlp-game-wiki.no" "https://nesmy.mariusdavid.fr/wiki/Accueil" "https://mlpgames.mariusdavid.fr" ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:9115";
          }
        ];
      }
      {
        job_name = "synapse";
        scrape_interval = "30s";
        metrics_path = "/_synapse/metrics";
        scheme = "https";
        static_configs = [
          {
            targets = [ "matrix.mariusdavid.fr" ];
          }
        ];
      }
    ];
  };
}
