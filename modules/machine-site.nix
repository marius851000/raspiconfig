{ lib, config, ... }:

let
  cfg = config.marinfra.machine-site;
in {
  options.marinfra.machine-site = {
    enable = lib.mkEnableOption "Per-machine test site";

    domain = lib.mkOption {
      default = "${config.networking.hostName}.net.mariusdavid.fr";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      virtualHosts."${cfg.domain}" = {
        enableACME = lib.mkDefault false;
        forceSSL = lib.mkDefault false;
      };
    };
  };
}