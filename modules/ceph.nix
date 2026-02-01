{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.ceph;
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

    marinfra.open_to_trusted.ports = [ "3300" ];
    marinfra.open_to_trusted.extra_filters = [
      "-A INPUT -p tcp --match multiport --dports 6800:7300 -j ACCEPT"
    ];

    services.ceph.enable = true;
    services.ceph.global = {
      fsid = "d236228d-314e-4eeb-b2c8-5edd6e4718a6";
      monHost = "zana.local";
      monInitialMembers = "zana";
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
