{ lib, pkgs, ...}:

{
  marinfra.ssl.extraDomain = [ "nesmy.mariusdavid.fr" ];

  services.mediawiki = {
    enable = true;
    database.type = "mysql";
    extensions = {
      ConfirmEdit = null;
      VisualEditor = null;
      Cite = null;
    };

    # create the user session "cache" table
    # CREATE TABLE `mwnix_persistant_cache` (
    #   `keyname` varbinary(255) NOT NULL DEFAULT '',
    #   `value` mediumblob DEFAULT NULL,
    #   `exptime` binary(14) NOT NULL,
    #   `modtoken` varbinary(17) NOT NULL DEFAULT '00000000000000000',
    #   `flags` int(10) unsigned DEFAULT NULL,
    #   PRIMARY KEY (`keyname`),
    #   KEY `exptime` (`exptime`)
    # );

    extraConfig = ''
      $wgLanguageCode = "fr";
      $wgRightsUrl = "https://creativecommons.org/licenses/by/4.0/";
      $wgRightsText = "CC-BY 4.0";
      $wgCiteBookReferencing = true;
      $wgDefaultUserOptions['visualeditor-editor'] = "visualeditor";

      // this cache option is only safe for single-server install (which is the case here)
      $wgMainCacheType = CACHE_ACCEL;
      // user may be logged out after a server restart if the user account cache is not persistent. Does not appear to still work..?
      // apparently, the DB objectcache is cleared when mediawiki-init is run...
      $wgObjectCaches["session_db"] = [ 'class' => SqlBagOStuff::class, 'loggroup' => 'SQLBagOStuff', 'tableName' => 'mwnix_persistant_cache' ];
      $wgSessionCacheType = "session_db";

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
