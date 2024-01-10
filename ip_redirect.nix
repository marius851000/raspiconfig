{ lib, ... }:

# My new home ISP does not provide static IPv4, so instead use the OVH server to redirect IPv4 traffic to the server via yggdrasil using nginx (IPv6 is left as-is)
let
  marella_yggdrasil_ip = "202:3679:f712:fd04:e3de:a123:caf4:580d";
  server_ip = "5.196.70.120";

  domains_to_proxy = [
    "paperless.mariusdavid.fr"
    "otp.mariusdavid.fr"
    "matrix.mariusdavid.fr"
    "archive.mariusdavid.fr"
    "hydra.mariusdavid.fr"
    "translate.mariusdavid.fr"
  ];
in
{
  marinfra.yggdrasil.enable = true;

  services.nginx = {
    # based upon https://stackoverflow.com/questions/34741571/nginx-tcp-forwarding-based-on-hostname
    streamConfig = ''
      map $ssl_preread_server_name $server_redirect {
        ${lib.concatLines (builtins.map (domain: "${domain} https_marella_backend;") domains_to_proxy)}
        default https_default_backend;
      }

      upstream https_default_backend {
        server 127.0.0.1:443;
      }

      upstream https_marella_backend {
        server [${marella_yggdrasil_ip}]:443;
      }

      server {
        listen ${server_ip}:443;
        proxy_pass $server_redirect;
        ssl_preread on;
      }
    '';

    virtualHosts = builtins.listToAttrs (
      builtins.map (domain: lib.nameValuePair domain {
        locations."/" = {
          proxyPass = "http://[${marella_yggdrasil_ip}]:80";
        };
      }) domains_to_proxy
    );
  };
}