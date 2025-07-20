{ pkgs, ... }:

rec {
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ /*"roundcube.mariusdavid.fr"*/ ];

  mailserver = {
    enable = true;
    fqdn = "mariusdavid.fr";
    domains = [ "hacknews.pmdcollab.org" "mariusdavid.fr" "reddit1.mariusdavid.fr" "reddit2.mariusdavid.fr" ];

    enablePop3 = true;
    enablePop3Ssl = true;

    stateVersion = 3;

    forwards = {
      "postmaster@hacknews.pmdcollab.org" = "marius@mariusdavid.fr";
      "postmaster@mariusdavid.fr" = "marius@mariusdavid.fr";
      "reddit1@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit2@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit3@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit4@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit5@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit6@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit7@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit8@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit9@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit10@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit11@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit12@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit13@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit14@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit15@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit16@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit17@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit18@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit19@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit20@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit21@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit22@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit23@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit24@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit25@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit26@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit27@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit28@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit29@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit30@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";
      "reddit31@hacknews.pmdcollab.org" = "reddit@hacknews.pmdcollab.org";

      "reddit32@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit33@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit34@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit35@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit36@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit37@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit38@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit39@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit40@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "reddit41@mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";

      "user50@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user51@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user52@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user53@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user54@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user55@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user56@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user57@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user58@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user59@reddit1.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";

      "user60@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user61@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user62@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user63@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user64@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user65@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user66@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user67@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user68@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user69@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user70@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user71@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user72@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user73@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #home
      "user74@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user75@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user76@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user77@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user78@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      "user79@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";
      #new
      "user80@reddit2.mariusdavid.fr" = "reddit@hacknews.pmdcollab.org";

      #TODO: postmaster@mariusdavid.fr
      #TODO: not forward, but instead the other stuff
    };
    loginAccounts = {
      "hacknews@hacknews.pmdcollab.org" = {
        hashedPasswordFile = "/secret-hacknews-mail-password.txt";
        #sendOnly = true;
        #sendOnlyRejectMessage = "This mail address is dedicated to sending update on the wiki. You can contact the administrator at mariusdavid@laposte.net (or other contact method displayed on-site).";
      };
      "peertube@mariusdavid.fr" = {
        hashedPasswordFile = "/secret-peertube-mail-password.txt";
      };
      "marius@mariusdavid.fr" = {
        hashedPasswordFile = "/secret-marius-password.txt";
        aliases = [ "@mariusdavid.fr" "@hacknews.pmdcollab.org" ];
      };
      "reddit@hacknews.pmdcollab.org" = {
        hashedPasswordFile = "/secret-reddit-account-email-pass.txt";
        aliases = [ "@reddit1.mariusdavid.fr" "@reddit2.mariusdavid.fr" ];
      };

      "mastodon@mariusdavid.fr" = {
        hashedPasswordFile = "/secret-mail-mastodon-hashed.txt";
      };
      "grafana@mariusdavid.fr" = {
        hashedPasswordFile = "/secret-mail-grafana-hashed.txt";
      };

      "jean@mariusdavid.fr" = {
        hashedPassword = "/secret-jean-password.txt";
      };
    };

    certificateScheme = "acme-nginx";
    certificateDomains = [ ];

    localDnsResolver = false;
  };

  services.rspamd.extraConfig = ''
    actions {
      reject = null; # Disable rejects, default is 15
      add_header = 6; # Add header when reaching this score
      greylist = null; # Apply greylisting when reaching this score
    }
  '';

  nixpkgs.overlays = [
    (self: super: {
      rspamd = super.rspamd.override {
        vectorscan = pkgs.hyperscan;
      };
    })
  ];

  security.acme.certs."mariusdavid.fr".postRun = ''
    systemctl reload postfix
    systemctl reload dovecot2
  '';

  services.roundcube = {
    enable = true;
    # this is the url of the vhost, not necessarily the same as the fqdn of
    # the mailserver
    hostName = "roundcube.mariusdavid.fr";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };


  services.dovecot2.sieve = {
    plugins = [ "sieve_imapsieve" "sieve_extprograms" ];
    extensions = [ "fileinto" ];
    globalExtensions = [ "+vnd.dovecot.pipe" "+vnd.dovecot.environment" ];
  };
}
