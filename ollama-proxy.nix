{}:

{ config, pkgs, ... }:

{
  marinfra.ssl.extraDomain = [ "ollama.mariusdavid.fr" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."ollama.mariusdavid.fr" = {
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://[201:c608:513e:2269:3d8d:b3eb:93c1:f1e7]:80";
        };
      };
    };
  };
}
