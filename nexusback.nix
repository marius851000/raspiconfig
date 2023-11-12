{ ... }:

{
  marinfra.ssl.extraDomain = [ "nexusback.mariusdavid.fr" ];

  services.nginx = {
    virtualHosts."nexusback.mariusdavid.fr" = {
      root = "/nexusback";
    };
  };

  services.syncthing.settings.folders.nexusback = {
    id = "94mz4-smeut";
    path = "/nexusback";
    devices = [ "mariuspc" ];
    ignorePerms = true;
  };
}