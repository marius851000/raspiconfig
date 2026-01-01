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

      // captcha stuff. Pretty permissive. Should be ok as long as I am not targetted.
      $wgCaptchaClass = 'QuestyCaptcha';
      $wgCaptchaQuestions = [
        'Quelle est la commune dont traite ce site ?' => 'Nesmy'
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
  };
}
