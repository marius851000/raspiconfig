{ pkgs, config, ... }:

{
  marinfra.ssl.extraDomain = [ "lamp.mariusdavid.fr" ];

  services.nginx = {
    # headlamp
    virtualHosts."lamp.mariusdavid.fr" = {
      locations."/" = {
        proxyPass = "http://${config.marinfra.info.nebula_address}:3080";
      };
    };
  };
}
