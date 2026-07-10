{ mlpgames_downloader_src }:

{ config, lib, pkgs, ... }:

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

  cfg = config.marinfra.mlpgames_mirror;
in
{

  options.marinfra.mlpgames_mirror = {
    enable = lib.mkEnableOption "mlpgames mirror";

    domain = lib.mkOption {
      type = lib.types.str;
    };

    backup_dir = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    marinfra.ssl.extraDomain = [ cfg.domain ];

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
        RUST_LOG = "info";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${server}/bin/mlp-games-mirror-serving ${cfg.backup_dir} 127.0.0.1 8073";
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
        ExecStart = "${pkgs.lib.getBin pkgs.python3.withPackages (ps: [ ps.requests ])}/bin/python3 ${mlpgames_downloader_src}/downloader.py ${cfg.backup_dir}";
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

    services.nginx.virtualHosts."${cfg.domain}" = {
      locations."/" = {
        proxyPass = "http://localhost:8073";
      };
    };
  };
}
