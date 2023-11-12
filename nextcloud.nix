{ pkgs, config, ... }:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "cloud.mariusdavid.fr" ];

  services.nextcloud = {
    enable = true;
    hostName = "cloud.mariusdavid.fr";
    database.createLocally = true;
    package = pkgs.nextcloud27;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/secret-nextcloud-admin.txt";
      overwriteProtocol = "https";
    };
    #enableBrokenCiphersForSSE = false;
    extraOptions = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
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