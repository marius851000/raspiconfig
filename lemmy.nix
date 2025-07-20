{ pkgs, ...}:

{
  marinfra.ssl.extraDomain = [ "lemmy.mariusdavid.fr" ];

  #services.postgresql.package = pkgs.postgresql_15;

  services.lemmy = {
    enable = true;
    nginx.enable = true;
    settings = {
      hostname = "lemmy.mariusdavid.fr";
      #database.port = null;
      email = {
        smtp_server = "mariusdavid.fr:587";
        smtp_login = "grafana@mariusdavid.fr";
        smtp_from_address = "grafana@mariusdavid.fr";
        tls_type = "startls";
      };
      prometheus = {
        bind = "127.0.0.1";
        port = 10002;
      };
      database = {
        pool_size = 30;
      };
    };
    smtpPasswordFile = "/secret-mail-grafana.txt";
    database.createLocally = true;
    database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "lemmy";
      scrape_interval = "20s";
      static_configs = [
        {
          targets = [ "localhost:10002" ];
        }
      ];
    }
  ];

  /*services.nginx.virtualHosts."lemmy.mariusdavid.fr" = {
    forceSSL = true;
    };*/

  #systemd.services.lemmy.environment.LEMMY_DATABASE_URL = pkgs.lib.mkForce "postgres:///lemmy?host=/run/postgresql&user=lemmy";

  services.pict-rs.port = 5934;
  services.pict-rs.package = pkgs.pict-rs;

  systemd.services.pict-rs.environment.PICTRS__SERVER__ADDRESS = "127.0.0.1:5934";
  systemd.services.pict-rs.environment.RUST_LOG = "debug,sled=info";
}
