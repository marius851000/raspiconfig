{ pkgs, config, ... }:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "cloud.mariusdavid.fr" ];

  services.nextcloud = {
    enable = true;
    hostName = "cloud.mariusdavid.fr";
    database.createLocally = true;
    package = pkgs.nextcloud32;
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

  # https://diogotc.com/blog/collabora-nextcloud-nixos/
  #
  #TODO: This doesn’t work. Fix.
  services.collabora-online = {
    enable = true;
    port = 9980; # default
    settings = {
      # Rely on reverse proxy for SSL
      ssl = {
        enable = false;
        termination = true;
      };

      # Listen on loopback interface only, and accept requests from ::1
      net = {
        listen = "loopback";
        post_allow.host = ["::1"];
      };

      # Restrict loading documents from WOPI Host nextcloud.example.com
      storage.wopi = {
        "@allow" = true;
        host = ["scrogne.local"];
      };

      # Set FQDN of server
      server_name = "collabora.mariusdavid.fr";
    };
  };
}
