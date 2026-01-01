{ lib, pkgs, ...}:

{
  marinfra.ssl.extraDomain = [ "nesmy.mariusdavid.fr" ];

  services.mediawiki = {
    enable = true;
    database.type = "mysql";
    extensions = {
      ConfirmEdit = null;
    };
    extraConfig = ''
      $wgLanguageCode = "fr";
      $wgRightsUrl = "https://creativecommons.org/licenses/by/3.0/";

      // this cache option is only safe for single-server install (which is the case here)
      $wgMainCacheType = CACHE_ACCEL;
      // user may be logged out after a server restart if the user account cache is not persistent. Does not appear to still work..?
      $wgMainCacheType = CACHE_DB;

      // captcha stuff. Pretty permissive. Should be ok as long as I am not targetted.
      $wgCaptchaClass = 'QuestyCaptcha';
      $wgCaptchaQuestions = [
        'Quelle est le nom de la commune dont traite ce site ?' => 'Nesmy'
      ];
      $wgGroupPermissions['*']['skipcaptcha'] = false;
      $wgGroupPermissions['user']['skipcaptcha'] = true;
      $wgCaptchaTriggers['edit'] = true;
      $wgCaptchaTriggers['create'] = true;
      $wgCaptchaTriggers['sendemail'] = true;
      $wgCaptchaTriggers['addurl'] = true;
      $wgCaptchaTriggers['createaccount'] = true;
      $wgCaptchaTriggers['badlogin'] = true;
      $wgCaptchaTriggers['badloginperuser'] = true;
    '';
    webserver = "nginx";
    nginx.hostName = "nesmy.mariusdavid.fr";
    passwordSender = "mediawiki@mariusdavid.fr";
    passwordFile = "/secret/mediawiki-password"; #TODO
    name = "Nesmy Wiki";

    phpPackage = pkgs.php83.buildEnv {
      extensions = { enabled, all }: enabled ++ [ all.apcu all.igbinary ];
    };
  };

  services.nginx.virtualHosts."nesmy.mariusdavid.fr" = {
    http3 = true;
    quic = true;
  };

  # opcache is loaded by default
  # apcu? in place
  # main cache? in place
  # sidebar cache?
  # caching proxy?
}
