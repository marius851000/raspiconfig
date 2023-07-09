{ pkgs, ...}:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "lemmy.mariusdavid.fr" ];

  services.lemmy = {
    enable = true;
    nginx.enable = true;
    settings = {
      hostname = "lemmy.mariusdavid.fr";
      database.host = "localhost";
      database.password = "localdbpass";
      #database.port = null;
    };
    database.createLocally = true;
  };

  services.nginx.virtualHosts."lemmy.mariusdavid.fr" = {
    useACMEHost = "mariusdavid.fr";
    forceSSL = true;
  };
  
  systemd.services.lemmy.environment.LEMMY_DATABASE_URL = pkgs.lib.mkForce "postgres:///lemmy?host=/run/postgresql&user=lemmy";

  services.pict-rs.port = 5934;
}