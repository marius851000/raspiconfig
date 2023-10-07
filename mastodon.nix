{ glitch-soc-package }:

{ config, pkgs, ... }:

{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ config.services.mastodon.extraConfig.WEB_DOMAIN ];

  services.mastodon = {
    #package = pkgs.callPackage glitch-soc-package {};
    enable = true;
    webProcesses = 1;
    webThreads = 2;
    sidekiqThreads = 1;
    localDomain = "mariusdavid.fr";
    smtp = {
      authenticate = true;
      user = "mastodon@mariusdavid.fr";
      host = "mariusdavid.fr";
      passwordFile = "/secret-mail-mastodon-clear.txt";
      createLocally = false;
      fromAddress = "mastodon@mariusdavid.fr";
    };
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
}