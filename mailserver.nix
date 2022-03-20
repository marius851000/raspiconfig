{ ... }:

{
  mailserver = {
    enable = true;
    fqdn = "hacknews.pmdcollab.org";
    domains = [ "hacknews.pmdcollab.org" ];

    forwards = {
      "postmaster@hacknews.pmdcollab.org" = "mariusdavid@laposte.net";
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
    };

    certificateScheme = 3;

    localDnsResolver = false;
  };
}