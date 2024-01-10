{ lib, config, ... }:

let
  cfg = config.marinfra.paperless;
in {
  options.marinfra.paperless = {
    enable = lib.mkEnableOption "Paperless-ngx";

    domain = lib.mkOption {
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 28981;
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    marinfra.ssl.extraDomain = [ cfg.domain ];

    services.nginx = {
      virtualHosts."${cfg.domain}" = {
        enableACME = lib.mkDefault false;
        forceSSL = lib.mkDefault false;

        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    services.paperless = {
      enable = true;
      port = cfg.port;
      address = "localhost";

      settings = {
        PAPERLESS_OCR_LANGUAGE = "fra+eng";
        PAPERLESS_OCR_USER_ARGS = "{\"continue_on_soft_render_error\": true}";
      };
    };
  };
}