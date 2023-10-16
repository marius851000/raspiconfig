{ lib, config, ... }:

let
  cfg = config.marinfra.ssl;
in {
  options.marinfra.ssl = {
    enable = lib.mkEnableOption "Enable per-machine automatic ssl certificates";

    baseDomain = lib.mkOption {
      default = config.marinfra.machine-site.domain;
      type = lib.types.str;
    };

    extraDomain = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    marinfra.machine-site.enable = true;

    services.nginx.virtualHosts = (lib.genAttrs cfg.extraDomain (x: {
      enableACME = false;
      forceSSL = true;
      useACMEHost = cfg.baseDomain;
    })) // {
      "${cfg.baseDomain}" = {
        enableACME = true;
        addSSL = true;
      };
    };

    security.acme.certs."${cfg.baseDomain}".extraDomainNames = cfg.extraDomain;
  };
}