{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.otp;
in {
  options.marinfra.otp.enable = lib.mkEnableOption "OpenTripPlanner (uglily hacked, but working)";

  config = lib.mkIf cfg.enable {
    services.syncthing.settings.folders.otp = {
      id = "nqjd2-drnwf";
      path = "/var/lib/otp";
      devices = [ "mariuspc" ];
      ignorePerms = true;
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/otp' 700 dokuwiki_pool dokuwiki_pool -"
    ];

    marinfra.ssl.extraDomain = [ "otp.mariusdavid.fr" ];

    services.nginx = {
      virtualHosts."otp.mariusdavid.fr" = {
        basicAuthFile = "/secret/nginx-pass-otp";
        locations."/" = {
          proxyPass = "http://localhost:9345/";
        };
      };
    };

    systemd.services = {
      opentripplanner = {
        description = "OpenTripPlanner";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = pkgs.writeScript "otp" ''
            #!${pkgs.bash}/bin/bash
            cd /var/lib/otp
            ${pkgs.openjdk}/bin/java -Xmx2G -jar otp-2.4.0-shaded.jar --load ./otp --serve --port 9345 --securePort 50434
          '';
          Restart = "always";
          RestartSec = "10s";
          User = "dokuwiki_pool";
          Group = "dokuwiki_pool";
        };
      };
    };
  };
}