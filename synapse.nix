{ pkgs, config, ... }:

let
  domain = "mariusdavid.fr";
in
{
  services.postgresql.enable = true;

  services.nginx =
    {
      virtualHosts."newsmatrix.pmdcollab.org" = {
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
      };

      virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "= /.well-known/matrix/server" = {
            extraConfig =
              let
                # use 443 instead of the default 8448 port to unite
                # the client-server and server-server port for simplicity
                server."m.server" = "${domain}:443";
              in
              ''
                add_header Content-Type application/json;
                return 200 '${builtins.toJSON server}';
              ''; 
          };
          "= /.well-known/matrix/client" = {
            extraConfig =
              let
                client = {
                  "m.homeserver" = { "base_url" = "https://${domain}"; };
                  "m.identity_server" = { "base_url" = "https://vector.im"; };
                };
                # ACAO required to allow element-web on any URL to request this json file
              in
              ''
                add_header Content-Type application/json;
                add_header Access-Control-Allow-Origin *;
                return 200 '${builtins.toJSON client}';
              '';
          };
          "/_matrix" = {
            proxyPass = "http://[::1]:8008"; # without a trailing /
          };
          "/element/" = {
            alias = let
              element = pkgs.element-web.override {
              conf = {
                default_server_config = {
                  "m.homeserver" = {
                    "base_url" = "https://${domain}";
                    "server_name" = "${domain}";
                  };
                };
                disable_guests = false;
              };
            };
          in
            "${element}/";
            extraConfig = ''
              add_header X-Frame-Options SAMEORIGIN;
              add_header X-Content-Type-Options nosniff;
              add_header X-XSS-Protection "1; mode=block";
              add_header Content-Security-Policy "frame-ancestors 'none'";
            '';
          };
          "= /element" = {
            return = "https://mariusdavid.fr/element/";
          };
        };
      };
    };


  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = domain;
      enable_metrics = true;
      allow_guest_access = true;
      enable_registration = false;
      enable_registration_without_verification = false;
      app_service_config_files = [
        "/var/lib/matrix-synapse/discord-registration.yaml"
      ];
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

  services.matrix-appservice-discord = {
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
  };

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

  systemd.services.compress_synapse = {
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
  };
}
