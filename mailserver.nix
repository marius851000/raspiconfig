{ ... }:

{
  mailserver = {
    enable = true;
    fqdn = "mariusdavid.fr";
    domains = [ "hacknews.pmdcollab.org" "mariusdavid.fr" ];

    forwards = {
      "postmaster@hacknews.pmdcollab.org" = "mariusdavid@laposte.net";
      #TODO: postmaster@mariusdavid.fr
      #TODO: not forward, but instead the other stuff
    };
    loginAccounts = {
      "hacknews@hacknews.pmdcollab.org" = {
        hashedPasswordFile = "/secret-hacknews-mail-password.txt";
        #sendOnly = true;
        #sendOnlyRejectMessage = "This mail address is dedicated to sending update on the wiki. You can contact the administrator at mariusdavid@laposte.net (or other contact method displayed on-site).";
      };
      "peertube@hacknews.pmdcollab.org" = {
        hashedPasswordFile = "/secret-peertube-mail-password.txt";
      };
      "marius@mariusdavid.fr" = {
        hashedPasswordFile = "/secret-marius-password.txt";
      };
    };

    certificateScheme = 3;
    certificateDomains = [ ];

    localDnsResolver = false;
  };

  security.acme.certs."mariusdavid.fr".postRun = ''
    systemctl reload postfix
    systemctl reload dovecot2
  '';
}