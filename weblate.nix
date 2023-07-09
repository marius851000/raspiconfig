{ pkgs, ... }:

{
  services.weblate = {
    enable = true;
    localDomain = "translate.mariusdavid.fr";
    djangoSecretKeyFile = "/secret_weblate";
    smtp = {
      #TODO: grant it its own user
      user = "grafana@mariusdavid.fr";
      host = "mariusdavid.fr";
      createLocally = false;
      passwordFile = "/secret-mail-grafana.txt";
    };
    extraConfig = "DEBUG = True";
  };
}