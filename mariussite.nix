{ ... }:

{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."mariusdavid.fr" = {
      root = ./mariussite;
      enableACME = true;
      forceSSL = true;
    };

    virtualHosts."reddit1.mariusdavid.fr" = {
      root = ./mariussite;
      enableACME = true;
      forceSSL = true;
    };
    
    virtualHosts."reddit2.mariusdavid.fr" = {
      root = ./mariussite;
      enableACME = true;
      forceSSL = true;
    };
  };
}