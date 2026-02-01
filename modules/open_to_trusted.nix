{ lib, config, pkgs, ... }:
let
  cfg = config.marinfra.open_to_trusted;

  trusted_ips = (builtins.filter (ip: ip != "") (
    builtins.map (m: m.options.marinfra.info.ygg_address.value) (
      builtins.attrValues config.marinfra.info.other_machines
    )
  )) ++ [
    "200:deb5:f162:56a0:b1d0:fee:6a44:9980" # TUF pc
    "201:c608:513e:2269:3d8d:b3eb:93c1:f1e7" # coryn
  ];
in
{
  options.marinfra.open_to_trusted = {
    ports = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
    extra_filters = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    networking.firewall.extraCommands = (lib.concatLines (builtins.map (ip6:
      (
        lib.concatLines
        (
          ((builtins.map (port:
            ''
              ip6tables -s ${ip6} -A INPUT -p tcp --dport ${port} -j ACCEPT
              ip6tables -s ${ip6} -A INPUT -p udp --dport ${port} -j ACCEPT
            ''
          ) cfg.ports)) ++
          ((builtins.map (extra:
            ''
              ip6tables -s ${ip6} ${extra}
            ''
          ) cfg.extra_filters))
        )
      )
    ) trusted_ips));
  };
}
