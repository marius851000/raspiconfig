{ lib, config, pkgs, ... }:
let
  cfg = config.marinfra.open_to_trusted;

  trusted_ips = [
    "200:e7e5:8090:9030:15d0:d8d4:8f8f:3ced" # scrogne
    "202:3679:f712:fd04:e3de:a123:caf4:580d" # marella
    "200:deb5:f162:56a0:b1d0:fee:6a44:9980" # TUF pc
    "201:4227:d97:c7f2:54bc:b9f4:a4:508c" # zana
    "201:c608:513e:2269:3d8d:b3eb:93c1:f1e7" # coryn
  ];
in
{
  options.marinfra.open_to_trusted = {
    ports = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    networking.firewall.extraCommands = (lib.concatLines (builtins.map (ip6:
      (lib.concatLines (builtins.map (port:
        ''
          ip6tables -s ${ip6} -A INPUT -p tcp --dport ${port} -j ACCEPT # ssh
          ip6tables -s ${ip6} -A INPUT -p udp --dport ${port} -j ACCEPT # ssh
        ''
      ) cfg.ports))
    ) trusted_ips));
  };
}
