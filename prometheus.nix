{pkgs, config, lib, ...}:

{
  services.prometheus = {
    enable = true;
    listenAddress = "localhost";
    retentionTime = "30d";
    exporters.nginx = {
      enable = true;
      listenAddress = "localhost";
    };
    exporters.node = {
      enable = true;
    };
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
    exporters.systemd = {
      enable = true;
      extraFlags = [
        "--systemd.collector.enable-ip-accounting"
      ];
    };
    scrapeConfigs = [
      {
        job_name = "systemd";
        scrape_interval = "20s";
        static_configs = [
          {
            targets = [ "localhost:9558" ];
          }
        ];
      }
      {
        job_name = "nginx";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = [ "localhost:9113" ];
          }
        ];
      }
      {
        job_name = "node";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
          }
        ];
      }
      {
        job_name = "blackbox";
        scrape_interval = "4s";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [
          {
            targets = [ "https://mariusdavid.fr" ];
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