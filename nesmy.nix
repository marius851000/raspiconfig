{ lib, pkgs, ...}:

{
  marinfra.ssl.extraDomain = [ "nesmy.mariusdavid.fr" ];

  networking.extraHosts = ''
    127.0.0.0 nesmy.mariusdavid.fr
  '';

  services.mediawiki = {
    enable = true;
    database.type = "mysql";
    extensions = {
      ConfirmEdit = null;
      VisualEditor = null;
      Cite = null;
      ParserFunctions = null;
      TitleKey = builtins.fetchGit {
        url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/TitleKey";
        rev = "a9255da4b05002600195a3efbc8770913bc172ab";
      };
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
      extensions = { enabled, all }: enabled ++ [ all.apcu ];
    };
  };

  services.nginx.virtualHosts."nesmy.mariusdavid.fr" = {
    http3 = true;
    quic = true;

    locations = {
      "/dumps/" = {
        alias = "/var/lib/mediawiki_nesmy_dump/";
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };

  # opcache is loaded by default
  # apcu? in place
  # main cache? in place
  # sidebar cache?
  # caching proxy?

  systemd.timers.mediawiki_nesmy_publish_dump = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "3600";
      FixedRandomDelay = "true";
      Persistent = "true";
    };
  };

  systemd.services.mediawiki_nesmy_publish_dump = {
    script = ''
      set -euxo pipefail
      cd /var/lib/mediawiki_nesmy_dump

      /run/current-system/sw/bin/mediawiki-maintenance dumpBackup.php --full > tmp/ongoing_backup.xml
      mv tmp/ongoing_backup.xml nesmy-wiki-dump-$(date '+%Y-%m-%d-%H:%M:%S').xml
      echo "✅ backup generated"

      find . -name "nesmy-wiki-dump-*.xml" -mtime +7 -delete
      echo "✅ old backup deleted (if it didn’t break horribly)"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "mediawiki";
      Group = "nginx";
    };
  };

  systemd.tmpfiles.rules = [
    "d '/var/lib/mediawiki_nesmy_dump' 755 mediawiki nginx -"
    "d '/var/lib/mediawiki_nesmy_dump/tmp' 700 mediawiki nginx -"
  ];
}
