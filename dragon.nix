{ depiction_map_src }:

{ pkgs, ... }:

let
  depiction_map = pkgs.rustPlatform.buildRustPackage {
    pname = "depiction_map";
    version = "git";

    src = depiction_map_src;

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];

    cargoLock = {
      lockFile = builtins.toPath "${depiction_map_src}/Cargo.lock";
      outputHashes = {
        "safe_join-0.1.0" = "sha256-LJ5eOgz+qxR1Gn0Z3BRQ15Jl7uR2DEc0b1NXH0q9vak=";
      };
    };
  };
in
{
  marinfra.ssl.extraDomain = [ "dragons.mariusdavid.fr" ];

  systemd.services.depiction_map = {
    enable = true;
    description = "depiction map of stuff";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${depiction_map}/bin/depiction_map /var/lib/depiction_map/dragon_ressource /var/lib/depiction_map/persisted_info --port 2653";
      Restart = "on-failure";
      RestartSec = 5;
      User = "depiction_map";
      Group = "depiction_map";
    };
  };

  systemd.tmpfiles.rules = [
    "d '/var/lib/depiction_map/' 770 depiction_map depiction_map -"
    "d '/var/lib/depiction_map/dragon_ressource' 770 depiction_map depiction_map -"
    "d '/var/lib/depiction_map/persisted_info' 770 depiction_map depiction_map -"
  ];

  users.users.depiction_map = {
    group = "depiction_map";
    isSystemUser = true;
  };
  users.groups.depiction_map = {};

  users.users.dokuwiki_pool = {
    extraGroups = [ "depiction_map" ];
  };

  services.syncthing.settings.folders.dragonsv2 = {
    id = "dragonsv2";
    path = "/var/lib/depiction_map/";
    devices = [ "mariuspc" ];
    ignorePerms = true;
  };

  services.nginx.virtualHosts."dragons.mariusdavid.fr" = {
    locations."/" = {
        proxyPass = "http://localhost:2653";
    };
  };
}
