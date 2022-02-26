{ pkgs, config, ... }:

let
  domain = "newsmatrix.pmdcollab.org";
in
{
  services.postgresql.enable = true;

  services.nginx =
    {
      virtualHosts."newsmatrix.pmdcollab.org" = {
        #root = "/site";
        root = "/nix";
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
        };
      };
      virtualHosts."hacknews.pmdcollab.org" = {
        locations = {
          "/element/" = {
            alias = let
              element = pkgs.element-web.override {
              conf = {
                default_server_config = {
                  "m.homeserver" = {
                    "base_url" = "https://newsmatrix.pmdcollab.org";
                    "server_name" = "newsmatrix.pmdcollab.org";
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
            return = "https://hacknews.pmdcollab.org/element/";
          };
        };
      };
    };


  services.matrix-synapse = {
    enable = true;
    server_name = domain;
    enable_metrics = true;
    allow_guest_access = true;
    listeners = [
      {
        port = 8008;
        bind_address = "::1";
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

  systemd.services.matrix-synapse = {
    serviceConfig = {
      TimeoutStartSec = 600;
    };
  };
}
