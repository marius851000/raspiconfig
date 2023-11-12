{ pkgs, config, ... }:

let
  domain = "mariusdavid.fr";
in
{
  marinfra.ssl.extraDomain = [ "matrix.mariusdavid.fr" ];

  services.postgresql.enable = true;

  services.nginx =
    {
      /*virtualHosts."newsmatrix.pmdcollab.org" = {
        root = "/dev/null";
        enableACME = true;
        forceSSL = true;

        locations = {
          "*" = {
            extraConfig = ''
              return 410;
            '';
          };
        };
      };*/

      virtualHosts."matrix.mariusdavid.fr" = {
        locations = {
          "/_matrix" = {
            proxyPass = "http://localhost:8008"; # without a trailing /
          };
          "/_synapse/metrics" = {
            proxyPass = "http://localhost:8008";
          };
        };
      };
    };


  services.matrix-synapse = {
    enable = true;
    settings = {
      experimental_features = {
        faster_joins = true;
      };
      presence.enabled = false;
      server_name = "mariusdavid.fr";
      enable_metrics = true;
      allow_guest_access = true;
      enable_registration = false;
      enable_registration_without_verification = false;
      app_service_config_files = [
        "/var/lib/matrix-synapse/discord-registration.yaml"
      ];
      media_retention = {
        remote_media_lifetime = "30d";
      };
      listeners = [
        {
          port = 8008;
          bind_addresses = [
            "::1"
            "127.0.0.1"
          ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" "metrics" ];
              compress = false;
            }
          ];
        }
      ];
    };
  };

  #systemd.services.matrix-synapse.serviceConfig.IOSchedulingClass = "idle";

  /*services.matrix-appservice-discord = {
    enable = true;
    environmentFile = "/secret-matrix-appservice-discord.env";
    settings = {
      bridge = {
        domain = "mariusdavid.fr";
        homeserverUrl = "https://mariusdavid.fr";

        determineCodeLanguage = true;
        disableJoinLeaveNotifications = true;
        disableInviteNotifications = true;
        enableSelfServiceBridging = true;
      };
      logging.console = "silly";
      #channel.namePattern = ":name";
    };
  };*/

  systemd.services.matrix-synapse = {
    serviceConfig = {
      TimeoutStartSec = 600;
    };
  };

  systemd.services.clear_empty_directory = {
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${pkgs.findutils}/bin/find /var/lib/matrix-synapse/media/remote_content -type d -empty -delete";
  };
  systemd.timers.clear_empty_directory = {
    wantedBy = [ "timers.target" ];
    partOf = [ "clear_empty_directory.service" ];
    timerConfig = {
      OnCalendar = "*-*-* *:04:10";
      Unit = "clear_empty_directory.service";
    };
  };

  /*systemd.services.compress_synapse = {
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${pkgs.matrix-synapse-tools.rust-synapse-compress-state}/bin/synapse_auto_compressor -p \"dbname=matrix-synapse host=/run/postgresql user=postgres\" -c 100 -n 1";
  };
  systemd.timers.compress_synapse = {
    wantedBy = [ "timers.target" ];
    partOf = [ "compress_synapse.service" ];
    timerConfig = {
      OnCalendar = "*-*-* *:*:30";
      Unit = "compress_synapse.service";
    };
  };*/
}
