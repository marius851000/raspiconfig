{ config, ... }:

{
  services.nginx = {
    virtualHosts."mariusdavid.fr" = {
      locations = {
        "/eespie/" = {
          proxyPass = "http://${config.marinfra.info.all_machines.zana.options.marinfra.info.nebula_address.value}:2345/";
          extraConfig = ''
            access_log off;
          '';
        };
      };
    };
  };
}
