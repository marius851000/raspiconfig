{ mariussite }:

{ pkgs, ... }:

let
  mariussite_instanced = import "${mariussite}/site.nix" { inherit pkgs; };
in
{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "dragons.mariusdavid.fr" ];
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."mariusdavid.fr" = {
      root = mariussite_instanced;
      enableACME = true;
      forceSSL = true;
    };

    virtualHosts."dragons.mariusdavid.fr" = {
      root = "/dragons/";
      useACMEHost = "mariusdavid.fr";
      forceSSL = true;
    };

    /*virtualHosts."reddit1.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;
    };
    
    virtualHosts."reddit2.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;
    };*/
  };

  services.syncthing.settings.folders.dragons = {
    id = "dragons";
    path = "/dragons";
    devices = [ "mariuspc" ];
    ignorePerms = true;
  };
}