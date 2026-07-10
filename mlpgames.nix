{ mlpgames_downloader_src }:

{ config, pkgs, ... }:

let
  server = pkgs.rustPlatform.buildRustPackage {
    pname = "mlpgames_server";
    version = "git";

    src = mlpgames_downloader_src;

    nativeBuildInputs = [ pkgs.gcc ];

    cargoLock = {
      lockFile = builtins.toPath "${mlpgames_downloader_src}/Cargo.lock";
    };
  };
in
{
  marinfra.ssl.extraDomain = [ "mlpgames.mariusdavid.fr" ];

  users.users.mlpgames = {
    group = "mlpgames";
    isSystemUser = true;
  };
  users.groups.mlpgames = {};

  systemd.services.mlpgames_mirror_server = {
    enable = true;
    description = "mlpgames downloader server";
    wantedBy = [ "multi-user.target" ];
    environment = {
      RUST_LOG = "trace";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${server}/bin/mlp-games-mirror-serving /mlpgamesdownload/dest/ 127.0.0.1 8073";
      Restart = "on-failure";
      RestartSec = 10;
      User = "mlpgames";
      Group = "mlpgames";
    };
  };

  systemd.services.mlpgames_mirrorer = {
    environment = {
      PATH = pkgs.lib.mkForce "${pkgs.lib.getBin pkgs.wget}/bin/";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.lib.getBin pkgs.python3.withPackages (ps: [ ps.requests ])}/bin/python3 ${mlpgames_downloader_src}/downloader.py /mlpgamesdownload/dest/";
      User = "mlpgames";
      Group = "mlpgames";
    };
  };

  systemd.timers.mlpgames_mirrorer = {
    wantedBy = [ "timers.target" ];
    partOf = [ "mlpgames_mirrorer.service" ];
    timerConfig = {
      OnCalendar = "*:0/2";
      Unit = "mlpgames_mirrorer.service";
    };
  };

  services.nginx.virtualHosts."mlpgames.mariusdavid.fr" = {
    locations."/" = {
      proxyPass = "http://localhost:8073";
    };
  };
}
