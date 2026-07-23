{ pkgs, config, lib, ... }:

{
  marinfra.ssl.extraDomain = [ "ceph.mariusdavid.fr" ];

  services.nginx = {
    virtualHosts."ceph.mariusdavid.fr" = {
      basicAuthFile = "/secret-nginx-auth";
      locations."/" = {
        #TODO: automatically switch between the ips depending on who is the current mgr.
        proxyPass = "http://10.100.0.3:9080";
      };
    };
  };
}
