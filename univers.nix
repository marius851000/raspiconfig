{ lib, pkgs, ... }:

{
  marinfra.ssl.extraDomain = [ "univers.mariusdavid.fr" ];

  services.dokuwiki.sites."univers.mariusdavid.fr" = {
    settings = {
      disableactions = [ "register" ];
      useacl = true;
      superuser = "marius";
    };
    acl = [
      {
        page = "*";
        actor = "@ALL";
        level = "read";
      }
      {
        page = "*";
        actor = "marius";
        level = "delete";
      }
    ];
  };
}
