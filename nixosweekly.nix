{ pkgs, lib, ... }:

{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."hacknews.pmdcollab.org" = {
      root = "/site";
      enableACME = true;
      addSSL = true;
    };

    virtualHosts.awstats = {
      listen = [
        {
          port = 90;
          addr = "0.0.0.0";
        }
      ];
    };

    statusPage = true;
  };

  security.acme = {
    email = "mariusdavid@laposte.net";
    acceptTerms = true;
  };

  services.prometheus = {
    enable = true;
    listenAddress = "localhost";
    exporters.nginx = {
      enable = true;
      listenAddress = "localhost";
    };
    exporters.node = {
      enable = true;
    };
    exporters.blackbox = {
      enable = true;
      configFile = builtins.toFile "blackbox.yml" (lib.generators.toYAML {} {
        modules = {
          http_2xx = {
            prober = "http";
          };
        };
      });
    };
    scrapeConfigs = [
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
        scrape_interval = "10s";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [
          {
            targets = [ "https://hacknews.pmdcollab.org" ];
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
            target_label = "__address__" ;
            replacement = "localhost:9115";
          }
        ];
      }
    ];
  };

  services.grafana = {
    addr = "0.0.0.0";
    enable = true;
    port = 2345;
  };

  services.awstats = {
    enable = true;
    updateAt = "hourly";
    configs = {
      nginxaws = {
        logFile = "/var/log/nginx/access.log";
        webService = {
          urlPrefix = "";
          hostname = "awstats";
          enable = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 2345 90 ];
}
