{ lib, pkgs, config, ... }:

let
  cfg = config.marinfra.nebula;
  machine_key = config.marinfra.info.this_machine_key;
in {
  options.marinfra.nebula = {
    enable = lib.mkEnableOption "Nebula mesh routing";

    lighthouse = {
      enable = lib.mkEnableOption "Lighthouse server";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nebula ];
    networking.firewall.allowedUDPPorts = [ 4242 ];

    services.nebula.networks.mariusnet = {
      enable = true;
      isLighthouse = cfg.lighthouse.enable;
      cert = "/secret/nebula-" + machine_key + ".crt";
      key = "/secret/nebula-" + machine_key + ".key";
      ca = "/secret/nebula-ca.crt";
      #TODO: auto-determine scrogne’s nebula IP
      staticHostMap = {
        "10.100.0.1" = [ "5.196.70.120:4242" ];
      };
      settings = {
        lighthouse = {
          interval = 60;
          hosts = lib.optionals (!cfg.lighthouse.enable) [ "10.100.0.1" ];
        };
        firewall = {
          outbound_action = "reject";
          inbound_action = "reject";
          outbound = [
            {
              port = "any";
              proto = "any";
              host = "any";
            }
          ];
          inbound = [
            {
              port = "any";
              proto = "icmp";
              host = "any";
            }
            {
              port = "80";
              proto = "any";
              host = "any";
            }
            {
              port = "443";
              proto = "any";
              host = "any";
            }
            #TODO: use the firewall module to configure stuff here?
          ];
        };
      };
    };
  };
}
