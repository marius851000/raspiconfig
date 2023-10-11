{ pkgs, ... }:

{
  services.weblate = {
    enable = true;
    localDomain = "translate.mariusdavid.fr";
    djangoSecretKeyFile = "/secret/secret_weblate";
    smtp = {
      #TODO: grant it its own user
      user = "grafana@mariusdavid.fr";
      host = "mariusdavid.fr";
      createLocally = false;
      passwordFile = "/secret/mail-grafana-password.txt";
    };
    #extraConfig = "DEBUG = True";
  };

  systemd.tmpfiles.rules = [
    "f /secret/mail-grafana-password.txt 700 weblate weblate"
    "f /secret/secret_weblate 700 weblate weblate"
  ];
}