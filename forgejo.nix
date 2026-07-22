{ lib, pkgs, config, ... }:

let
  domain = "mlpgit.mariusdavid.fr";
in {
  marinfra.ssl.extraDomain = [ domain ];
  services.nginx = {
    virtualHosts."${domain}" = {
      extraConfig = ''
        client_max_body_size 0;
        proxy_read_timeout 60s;
      '';
      locations."/".proxyPass = "http://localhost:4593";
    };

    eventsConfig = ''
      worker_connections 10240;
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2223 ];

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        HTTP_PORT = 4593;

        DISABLE_SSH = false;
        START_SSH_SERVER = true;
        SSH_PORT = 2223;
        SSH_LISTEN_PORT = 2223;
      };
      security = {
        LOGIN_REMEMBER_DAYS = 356;
      };
      service.DISABLE_REGISTRATION = true;
      cache = {
        ADAPTER = "twoqueue";
        HOST = ''{"size":100, "recent_ratio":0.25, "ghost_ratio":0.5}'';
      };
      "repository.signing" = {
        DEFAULT_TRUST_MODEL = "committer";
      };
      # actions is probably not that much needed
      #TODO: mailer
      #TODO: captcha? open registration?
    };
  };

  # remember to change the password once created!
  /*systemd.services.forgejo.preStart = let
    adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
  in ''
    ${adminCmd} create --admin --email "marius@mariusdavid.fr" --username marius851000 --password "AIZEFJZIEFJZIfzfe123" || true
  '';*/

}
