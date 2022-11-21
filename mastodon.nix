{ config, pkgs, ... }:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ config.services.mastodon.extraConfig.WEB_DOMAIN ];

  services.mastodon = {
    enable = true;
    webProcesses = 1;
    sidekiqThreads = 2;
    localDomain = "mariusdavid.fr";
    smtp = {
      authenticate = true;
      user = "mastodon@mariusdavid.fr";
      host = "mariusdavid.fr";
      passwordFile = "/secret-mail-mastodon-clear.txt";
      createLocally = false;
      fromAddress = "mastodon@mariusdavid.fr";
    };
    package = pkgs.mastodon.overrideAttrs (old: {
      patches = [
      ];
    });
    configureNginx = false;
    enableUnixSocket = true;
    extraConfig = {
      WEB_DOMAIN = "mastodon.mariusdavid.fr";
      SINGLE_USER_MODE = "true";
      DEFAULT_LOCALE = "fr";
    };
  };

  users.groups.mastodon.members = [ "nginx" ];

  #TODO: upstream WEB_DOMAIN stuff to nixpkgs

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."mariusdavid.fr" = {
      locations."/.well-known/webfinger" = {
        return = "301 https://mastodon.mariusdavid.fr$request_uri";
      };
    };

    virtualHosts."${config.services.mastodon.extraConfig.WEB_DOMAIN}" = {
      root = "${config.services.mastodon.package}/public/";
      forceSSL = true; # mastodon only supports https
      useACMEHost = "mariusdavid.fr";

      locations."/system/".alias = "/var/lib/mastodon/public-system/";

      locations."/" = {
        tryFiles = "$uri @proxy";
      };

      locations."@proxy" = {
        proxyPass = "http://unix:/run/mastodon-web/web.socket";
        proxyWebsockets = true;
      };

      locations."/api/v1/streaming/" = {
        proxyPass ="http://unix:/run/mastodon-streaming/streaming.socket";
        proxyWebsockets = true;
      };
    };
  };

  systemd.services.gc_mastodon_cache = {
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "mastodon";
    serviceConfig.ExecStart = "/etc/profiles/per-user/mastodon/bin/mastodon-env /etc/profiles/per-user/mastodon/bin/tootctl media remove --days=0 --concurrency=1";
  };
  systemd.timers.gc_mastodon_cache = {
    wantedBy = [ "postgresql.target" ];
    partOf = [ "gc_mastodon_cache.service" ];
    timerConfig = {
      OnCalendar = "*-*-* *:04:00";
      Unit = "gc_mastodon_cache.service";
    };
  };
}