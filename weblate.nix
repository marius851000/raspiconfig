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
      passwordFile = "/secret/mail-grafana-password.txt";
    };
    #extraConfig = "DEBUG = True";
    extraConfig = ''
      del VCS_BACKENDS
      DEBUG = True
    '';
  };

  systemd.services.weblate.environment = {
    GUNICORN_CMD_ARGS = "--timeout=1200";
  };

  systemd.tmpfiles.rules = [
    "f /secret/mail-grafana-password.txt 700 weblate weblate"
    "f /secret/secret_weblate 700 weblate weblate"
  ];
}