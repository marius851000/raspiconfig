{ pkgs, config, ...}:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "lemmy.mariusdavid.fr" ];

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
    };
    smtpPasswordFile = "/secret-mail-grafana.txt";
    database.createLocally = true;
    database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
  };

  services.nginx.virtualHosts."lemmy.mariusdavid.fr" = {
    useACMEHost = "mariusdavid.fr";
    forceSSL = true;
  };
  
  #systemd.services.lemmy.environment.LEMMY_DATABASE_URL = pkgs.lib.mkForce "postgres:///lemmy?host=/run/postgresql&user=lemmy";

  services.pict-rs.port = 5934;
  services.pict-rs.package = pkgs.pict-rs;

  systemd.services.pict-rs.environment.PICTRS__SERVER__ADDRESS = "127.0.0.1:5934";
}