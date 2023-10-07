{ pkgs, ...}:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "lemmy.mariusdavid.fr" ];

  #services.postgresql.package = pkgs.postgresql_15;

  services.lemmy = {
    enable = true;
    nginx.enable = true;
    settings = {
      hostname = "lemmy.mariusdavid.fr";
      #database.port = null;
    };
    database.createLocally = true;
    database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
  };

  services.nginx.virtualHosts."lemmy.mariusdavid.fr" = {
    useACMEHost = "mariusdavid.fr";
    forceSSL = true;
  };
  
  #systemd.services.lemmy.environment.LEMMY_DATABASE_URL = pkgs.lib.mkForce "postgres:///lemmy?host=/run/postgresql&user=lemmy";

  services.pict-rs.port = 5934;
}