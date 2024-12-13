{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.ceph;
  trusted_ips = [
    "202:3679:f712:fd04:e3de:a123:caf4:580d"
    "200:e7e5:8090:9030:15d0:d8d4:8f8f:3ced"
    "200:deb5:f162:56a0:b1d0:fee:6a44:9980" #TUF pc
  ];
in {
  options.marinfra.ceph = {
    enable = lib.mkEnableOption "Global CEPH settings";

    daemon_name = lib.mkOption {
      type = lib.types.str;
    };

    mon-mgr = {
      enable = lib.mkEnableOption "CEPH mon and mgr";
    };

    osd = {
      storages = lib.mkOption {
        type = lib.types.listOf lib.types.number;
        default = [];
      };
    };

    mds = {
      enable = lib.mkEnableOption "CEPH mds";
    };
  };

  config = lib.mkIf cfg.enable ({
    environment.systemPackages = [ pkgs.ceph ];

    networking.firewall.extraCommands = lib.concatLines (builtins.map (ip6: ''
      ip6tables -s ${ip6} -A INPUT -p tcp --dport 3300 -j ACCEPT
      ip6tables -s ${ip6} -A INPUT -p tcp --match multiport --dports 6800:7300 -j ACCEPT
    '') trusted_ips);

    services.ceph.enable = true;
    services.ceph.global = {
      fsid = "dfeed42b-650f-470d-a0e2-655f82a51651";
      monHost = "[202:3679:f712:fd04:e3de:a123:caf4:580d]"; # marella
      monInitialMembers = "marella";
    };

    services.ceph.extraConfig = {
      "ms bind ipv6" = "true";
      "ms_bind_msgr1" = "false";
      "ms_bind_msgr2" = "true";
      "auth_allow_insecure_global_id_reclaim" = "false";
      mon_allow_pool_size_one = "true";

      # reduce memory usage at the cost of caching
      bluestore_cache_autotune = "false";
      bluestore_cache_size = "200MiB";
      osd_memory_target = "200MiB";
    };

    services.ceph.mon = lib.mkIf cfg.mon-mgr.enable {
      enable = true;
      daemons = [ cfg.daemon_name ];
    };

    services.ceph.mgr = lib.mkIf cfg.mon-mgr.enable {
      enable = true;
      daemons = [ cfg.daemon_name ];
    };

    services.ceph.mds = lib.mkIf cfg.mds.enable {
      enable = true;
      daemons = [ cfg.daemon_name ];
    };
    
    services.ceph.osd = lib.mkIf (cfg.osd.storages != []) {
      enable = true;
      # ids must be number... I’m deceived (until they can be auto-attributed...)
      daemons = builtins.map (storage_id: builtins.toString storage_id) cfg.osd.storages;
    };
  });
}