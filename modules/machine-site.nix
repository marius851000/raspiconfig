{ lib, config, ... }:

let
  cfg = config.marinfra.machine-site;
in {
  options.marinfra.machine-site = {
    enable = lib.mkEnableOption "Per-machine test site. Will use <config.networking.hostName>.net.mariusdavid.fr";
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      virtualHosts."${config.networking.hostName}.net.mariusdavid.fr" = {
        enableACME = false;
        forceSSL = false;
      };
    };
  };
}