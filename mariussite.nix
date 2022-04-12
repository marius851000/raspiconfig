{ mariussite }:

{ pkgs, ... }:

let
  mariussite_instanced = import "${mariussite}/site.nix" { inherit pkgs; };
in
{
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

    virtualHosts."reddit1.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;
    };
    
    virtualHosts."reddit2.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;
    };
  };
}