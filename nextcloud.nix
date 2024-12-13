{ pkgs, config, ... }:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "cloud.mariusdavid.fr" ];

  services.nextcloud = {
    enable = true;
    hostName = "cloud.mariusdavid.fr";
    database.createLocally = true;
    package = pkgs.nextcloud30;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/secret-nextcloud-admin.txt";
    };
    #enableBrokenCiphersForSSE = false;
    settings = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
      overwriteprotocol = "https";
    };
    enableImagemagick = true;
    configureRedis = true;
    webfinger = true;
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    useACMEHost = "mariusdavid.fr";
  };
}