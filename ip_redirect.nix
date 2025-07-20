{ lib, ... }:

# My new home ISP does not provide static IPv4, so instead use the OVH server to redirect IPv4 traffic to the server via yggdrasil using nginx (IPv6 is left as-is)
let
  marella_yggdrasil_ip = "202:3679:f712:fd04:e3de:a123:caf4:580d";
  noctus_yggdrasil_ip = "200:6233:ac7:f76c:ef8f:e313:aa1:b882";
  server_ip = "5.196.70.120";
  server_ip_v6 = "2001:41d0:e:378::1";

  domains_to_proxy_to_marella = [
    "paperless.mariusdavid.fr"
    "otp.mariusdavid.fr"
    "matrix.mariusdavid.fr"
    "archive.mariusdavid.fr"
    "hydra.mariusdavid.fr"
    "translate.mariusdavid.fr"
    "marella.net.mariusdavid.fr"
    "ceph.mariusdavid.fr"
    "torrent.mariusdavid.fr"
  ];
  domains_to_proxy_to_noctus = [
    "noctus.net.mariusdavid.fr"
    "lemmy.mariusdavid.fr"
  ];
in
{
  marinfra.yggdrasil.enable = true;

  services.nginx = {
    defaultSSLListenPort = 444;

    appendHttpConfig = ''
      port_in_redirect off;
    '';

    # based upon https://stackoverflow.com/questions/34741571/nginx-tcp-forwarding-based-on-hostname
    streamConfig = ''
      map $ssl_preread_server_name $server_redirect {
      ${lib.concatLines (builtins.map (domain: "${domain} https_marella_backend;") domains_to_proxy_to_marella)}
      ${lib.concatLines (builtins.map (domain: "${domain} https_noctus_backend;") domains_to_proxy_to_noctus)}
        default https_default_backend;
      }

      upstream https_default_backend {
        server 127.0.0.1:444;
      }

      upstream https_marella_backend {
        server [${marella_yggdrasil_ip}]:443;
      }

      upstream https_noctus_backend {
        server [${noctus_yggdrasil_ip}]:443;
      }

      server {
        listen 0.0.0.0:443;
        listen [::]:443;
        proxy_pass $server_redirect;
        ssl_preread on;
      }
    '';

    virtualHosts = builtins.listToAttrs (
      (builtins.map (domain: lib.nameValuePair domain {
        locations."/" = {
          proxyPass = "http://[${marella_yggdrasil_ip}]:80";
        };
      }) domains_to_proxy_to_marella)
      ++
      (builtins.map (domain: lib.nameValuePair domain {
        locations."/" = {
          proxyPass = "http://[${noctus_yggdrasil_ip}]:80";
        };
      }) domains_to_proxy_to_noctus)
    );
  };
}
