{ lib, config, ... }:

let
  cfg = config.marinfra.yggdrasil;
in {
  options.marinfra.yggdrasil = {
    enable = lib.mkEnableOption "Yggdasil";
  };

  config = lib.mkIf cfg.enable {
    services.yggdrasil = {
      enable = true;
      settings = {
        Peers = [
          "tls://163.172.31.60:12221?key=060f2d49c6a1a2066357ea06e58f5cff8c76a5c0cc513ceb2dab75c900fe183b&sni=jorropo.net"
          "tls://[2001:470:1f13:e56::64]:39575"
          "tls://fr2.servers.devices.cwinfo.net:23108"
          "tls://supergay.network:443"
          "tls://158.101.229.219:17001"
          "tls://mariusdavid.fr:6509"
        ];
        Listen = [
          "tls://0.0.0.0:6509"
          "tls://[::]:6509"
        ];
        MulticastInterfaces = [
          {
            Regex = "enp1s0";
            Beacon = true;
            Listen = true;
            Port = 9001;
            Priority = 100;
          }
        ];
      };
      persistentKeys = true;
      openMulticastPort = true;
    };
    networking.firewall.allowedTCPPorts = [ 6509 ];
    networking.firewall.allowedUDPPorts = [ 6509 ];
  };
}