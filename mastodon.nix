{ config, ... }:

{
  /*services.mastodon = {
    enable = true;
    webProcesses = 2;
    localDomain = "testmastodon.mariusdavid.fr";
    smtp = {
      authenticate = true;
      user = "mastodon@mariusdavid.fr";
      host = "mariusdavid.fr";
      passwordFile = "/secret-mail-mastodon-clear.txt";
      createLocally = false;
      fromAddress = "mariusdavid.fr";
    };
    configureNginx = false;
    extraConfig = {
      WEB_DOMAIN = "testmastodonwebdomain.mariusdavid.fr";
    };
  };*/

  #TODO: upstream WEB_DOMAIN stuff to nixpkgs

  /*services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."${config.services.mastodon.localDomain}" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;

      locations."/.well-known/webfinger" = {
        return = "301 https://testmastodonwebdomain.mariusdavid.fr$request_uri";
      };
    };

    virtualHosts."${config.services.mastodon.extraConfig.WEB_DOMAIN}" = {
        root = "${config.services.mastodon.package}/public/";
        forceSSL = true; # mastodon only supports https
        enableACME = true;

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
  };*/
}