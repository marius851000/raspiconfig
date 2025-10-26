{ lib, ... }:

# My new home ISP does not provide static IPv4, so instead use the OVH server to redirect IPv4 traffic to the server via yggdrasil using nginx (IPv6 is left as-is)
let
  marella_yggdrasil_ip = "202:3679:f712:fd04:e3de:a123:caf4:580d";
  coryn_yggdrasil_ip = "201:c608:513e:2269:3d8d:b3eb:93c1:f1e7";
  zana_yggdrasil_ip = "201:4227:d97:c7f2:54bc:b9f4:a4:508c";
  server_ip = "5.196.70.120";
  server_ip_v6 = "2001:41d0:e:378::1";

  domains_to_proxy_to_marella = [
    "paperless.mariusdavid.fr"
    "otp.mariusdavid.fr"
    "archive.mariusdavid.fr"
    "hydra.mariusdavid.fr"
    "marella.net.mariusdavid.fr"
    "ceph.mariusdavid.fr"
    "torrent.mariusdavid.fr"
  ];
  domains_to_proxy_to_coryn = [
    "ollama.mariusdavid.fr"
  ];
  domains_to_proxy_to_zana = [
    "zana.net.mariusdavid.fr"
    "translate.mariusdavid.fr"
    "matrix.mariusdavid.fr"
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
      ${lib.concatLines (builtins.map (domain: "${domain} https_coryn_backend;") domains_to_proxy_to_coryn)}
      ${lib.concatLines (builtins.map (domain: "${domain} https_zana_backend;") domains_to_proxy_to_zana)}
        default https_default_backend;
      }

      upstream https_default_backend {
        server 127.0.0.1:444;
      }

      upstream https_marella_backend {
        server [${marella_yggdrasil_ip}]:443;
      }

      upstream https_coryn_backend {
        server [${coryn_yggdrasil_ip}]:443;
      }

      upstream https_zana_backend {
        server [${zana_yggdrasil_ip}]:443;
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
          proxyPass = "http://[${coryn_yggdrasil_ip}]:80";
        };
      }) domains_to_proxy_to_coryn)
      ++
      (builtins.map (domain: lib.nameValuePair domain {
        locations."/" = {
          proxyPass = "http://[${zana_yggdrasil_ip}]:80";
        };
      }) domains_to_proxy_to_zana)
    );
  };
}
