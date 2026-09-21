{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.ceph;
in {
  options.marinfra.ceph = {
    enable = lib.mkEnableOption "Global CEPH settings";

    daemon_name = lib.mkOption {
      type = lib.types.str;
    };

    mon = {
      enable = lib.mkEnableOption "CEPH mon";
    };

    mgr = {
      enable = lib.mkEnableOption "CEPH mgr";
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

  # https://github.com/NixOS/nixpkgs/issues/542206
  config = lib.mkIf cfg.enable ({
    nixpkgs.overlays = [
      (final: prev:
      {
        ceph = (prev.ceph.overrideScope (_: prev:
        {
          # not sure if needed or effective
          arrow-cpp = null;
          ceph = prev.ceph.overrideAttrs ({ cmakeFlags ? [], ... }: { cmakeFlags = cmakeFlags ++
          [
            (final.lib.cmakeBool "WITH_RADOSGW_SELECT_PARQUET" false)
            (final.lib.cmakeBool "WITH_RADOSGW_ARROW_FLIGHT" false)
          ]; });
        })).ceph;
      })
    ];

    environment.systemPackages = [ pkgs.ceph ];

    services.nebula.networks.mariusne.settings.firewall.inbound = [
      {
        port = "3300";
        proto = "any";
        host = "any";
      }
      {
        port = "6800-7300";
        proto = "tcp";
        host = "any";
      }
      {
        port = "9080";
        proto = "tcp";
        host = "scrogne";
      }
    ];

    services.ceph.enable = true;
    services.ceph.global = {
      fsid = "d236228d-314e-4eeb-b2c8-5edd6e4718a6";
      monHost = "10.100.0.2, 10.100.0.3, 10.100.0.1";
      monInitialMembers = "zana, marella, scrogne";
    };

    services.ceph.extraConfig = {
      ms_bind_msgr1 = "false";
      ms_bind_msgr2 = "true";
      auth_allow_insecure_global_id_reclaim = "false";
      mon_allow_pool_size_one = "false";

      # reduce memory usage at the cost of caching
      bluestore_cache_autotune = "false";
      bluestore_cache_size = "200MiB";
      osd_memory_target = "200MiB";
    };

    services.ceph.mon = lib.mkIf cfg.mon.enable {
      enable = true;
      daemons = [ cfg.daemon_name ];
      extraConfig = {
        public_addr = config.marinfra.info.nebula_address;
        osd_erasure_code_plugins = ""; # jerasure fail to load on Scrogne due to "illegal instruction" for some reason. Jerasure should auto‑detect extension.
      };
    };

    services.ceph.mgr = lib.mkIf cfg.mgr.enable {
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
