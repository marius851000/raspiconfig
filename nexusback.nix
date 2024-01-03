{ ... }:

{
  marinfra.ssl.extraDomain = [ "archive.mariusdavid.fr" ];

  services.nginx = {
    virtualHosts."archive.mariusdavid.fr" = {
      root = "/archive";
      extraConfig = "autoindex on;";
    };
  };

  services.syncthing.settings.folders.nexusback = {
    id = "94mz4-smeut";
    path = "/nexusback";
    devices = [ "mariuspc" ];
    ignorePerms = true;
  };
}