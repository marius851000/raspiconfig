{ pmd_hack_archive_server, system }:
{ pkgs, lib, config, ... }:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "hacknews.pmdcollab.org" "reddit1.mariusdavid.fr" "reddit2.mariusdavid.fr" ];

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    package = pkgs.nginxQuic;

    virtualHosts."hacknews.pmdcollab.org" = {
      root = "/site";
      useACMEHost = "mariusdavid.fr";
      enableACME = false;
      forceSSL = true;
      http3 = true;
      locations = {
        "/eespie/" = {
          proxyPass = "http://localhost:2345/";
          extraConfig = ''
            access_log off;
          '';
        };
        "/.git" = {
          return = "404";
        };
        "/.gitignore" = {
          return = "404";
        };
        "/hacks" = {
          proxyPass = "http://localhost:12000";
        };
        "= /hacks" = {
          return = "https://hacknews.pmdcollab.org/hacks/";
        };
        "/archive" = {
          extraConfig = ''
            autoindex on;
          '';
        };

        "/feeds/all.atom.xml" = {
          return = "https://hacknews.pmdcollab.org/feed.php?type=atom&mode=list&ns=";
        };

        "/feeds/all.rss.xml" = {
          return = "https://hacknews.pmdcollab.org/feed.php?mode=list&ns=";
        };

        "~ /(conf/|bin/|inc/|install.php)" = {
          extraConfig = "deny all;";
        };

        "~ ^/data/" = {
          root = "/site/data";
          extraConfig = "internal;";
        };

        "~ ^/lib.*\.(js|css|gif|png|ico|jpg|jpeg)$" = {
          extraConfig = "expires 365d;";
        };
        
        "/_matrix" = {
          extraConfig = ''
            return 410;
          '';
        };

        "/" = {
          priority = 1;
          index = "doku.php";
          extraConfig = ''try_files $uri $uri/ @dokuwiki;'';
        };

        "@dokuwiki" = {
          extraConfig = ''
            # rewrites "doku.php/" out of the URLs if you set the userwrite setting to .htaccess in dokuwiki config page
            rewrite ^/_media/(.*) /lib/exe/fetch.php?media=$1 last;
            rewrite ^/_detail/(.*) /lib/exe/detail.php?media=$1 last;
            rewrite ^/_export/([^/]+)/(.*) /doku.php?do=export_$1&id=$2 last;
            rewrite ^/(.*) /doku.php?id=$1&$args last;
          '';
        };

        "~ \\.php$" = {
          extraConfig = ''

            try_files $uri $uri/ /doku.php;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param REDIRECT_STATUS 200;
            fastcgi_pass unix:${config.services.phpfpm.pools."dokuwiki".socket};
          '';
        };
      };
    };

    /*virtualHosts."tmpboard.mariusdavid.fr" = {
      root = "/dev/null";
      useACMEHost = "mariusdavid.fr";
      enableACME = false;
      forceSSL = true;
      http3 = true;
      locations = {
        "/" = {
          proxyPass = "http://[200:deb5:f162:56a0:b1d0:fee:6a44:9980]:6006";
        };
      };
    };*/

    statusPage = true;

    # based on https://www.supertechcrew.com/anonymizing-logs-nginx-apache/
    # anonymize IP address, by just keeping whether it is an ipv6 or ipv4 ip (updated from previously, where I kept the first 2 bytes)
    appendHttpConfig = ''
      map $remote_addr $remote_addr_anon {
        ~(?P<ip>\d+\.\d+)\.\d+\.    0.0.0.0;
        ~(?P<ip>[^:]+:[^:]+):       ::;
        # IP addresses to not anonymize (such as your server)
        127.0.0.1                   $remote_addr;
        ::1                         $remote_addr;
        192.168.0.254               $remote_addr;
        default                     0.0.0.0;
      }

        log_format  anon_ip   '$remote_addr_anon - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent"';

        access_log /var/log/nginx/access.log anon_ip;
    '';
  };

  services.phpfpm.pools.dokuwiki = {
    user = "dokuwiki_pool";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };

  users.groups.dokuwiki_pool = {};
  users.users.dokuwiki_pool = {
    isSystemUser = true;
    group = "dokuwiki_pool";
  };



  services.phpfpm.phpPackage = (
    pkgs.php80.withExtensions (
      { enabled, all }: with all; [
        pdo
        pdo_mysql
        xdebug
        dom
        filter
        iconv
        openssl
        mbstring
        simplexml
        curl
        filter
        session
        tokenizer
      ]
    )
  );

  #TODO: would be a good idea to put that to a network only shared with hackarchive. I think systemd can do it.
  services.couchdb = {
    enable = true;
    adminPass = "dontneedapasswordforlocalsystem";
  };

  systemd.services.hackarchive = {
    enable = true;
    description = "Marius's hack archive front-end";
    wantedBy = [ "multi-user.target" ];
    environment = {
      RUST_LOG = "info";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pmd_hack_archive_server.packages."${system}".pmd_hack_archive_server}/bin/server /site/archive ${pmd_hack_archive_server.packages."${system}".pmd_hack_archive_server.src}/locales localhost:12000 https://hacknews.pmdcollab.org/hacks hacks http://127.0.0.1:5984 admin dontneedapasswordforlocalsystem";
      Restart = "on-failure";
      RestartSec = 60;
    };
  };

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
            targets = [ "https://hacknews.pmdcollab.org" "https://translate.mariusdavid.fr" ];
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
        static_configs = [
          {
            targets = [ "[::1]:8008" ];
          }
        ];
      }
    ];
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

  services.awstats = {
    enable = true;
    updateAt = "hourly";
    configs = {
      nginxaws = {
        logFile = "/var/log/nginx/access.log";
        webService = {
          urlPrefix = "";
          hostname = "127.0.0.1:90";
          enable = false;
        };
      };
    };
  };

  /*services.nginx.virtualHosts."awstats.mariusdavid.fr" = {
    enableACME = true;
    forceSSL = true;

    basicAuthFile = "/secret-nginx-auth";

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:90";
      };
    };
  };*/
  
  /*services.nginx.virtualHosts."127.0.0.1:90" = {
    listen = [
      {
        port = 90;
        addr = "127.0.0.1";
      }
    ];
  };*/

  /*services.vsftpd = {
    enable = true;
    anonymousUser = true;
    anonymousUserHome = "/site";
    };*/

  /*services.loki = {
    enable = true;
    configuration = {
    auth_enabled = false;
    server = {
    http_listen_port = 3100;
    #grpc_listen_port = 9096;
    };
    ingester = {
    lifecycler = {
    address = "127.0.0.1";
    ring = {
    kvstore = {
    store = "inmemory";
    };
    replication_factor = 1;
    };
    final_sleep = "0s";
    };
    chunk_idle_period = "5m";
    chunk_retain_period = "30s";
    }
    }
    };*/

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
