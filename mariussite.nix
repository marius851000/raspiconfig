{ mariussite }:

{ pkgs, ... }:

let
  mariussite_instanced = import "${mariussite}/site.nix" { inherit pkgs; };
in
{
  marinfra.ssl.extraDomain = [ "dragons.mariusdavid.fr" ];

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."mariusdavid.fr" = {
      root = mariussite_instanced;
      #TODO: Do not use machine certificate due to the mailserver
      enableACME = true;
      forceSSL = true;
    };

    virtualHosts."dragons.mariusdavid.fr" = {
      root = "/dragons/";
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