{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.kubernetes;
in {
  options.marinfra.kubernetes = {
    enable = lib.mkEnableOption "Enable Kubernetes";

    master = {
      enable = lib.mkEnableOption "Enable Kubernetes master";

      clusterInit = lib.mkEnableOption "init cluster on this host";
    };
  };

  config = lib.mkIf cfg.enable {
    # packages for administration tasks
    environment.systemPackages = with pkgs; [
      kompose
      kubectl
      kubernetes
      kubernetes-helm
      helmfile
    ];

    services.nebula.networks.mariusnet.settings.firewall.inbound = [
      # servers -> servers, Required only for HA with embedded etcd
      {
        port = "2379-2380";
        proto = "tcp";
        host = "any";
      }
      # agents -> servers, K3s supervisor and Kubernetes API Server
      {
        port = "6443";
        proto = "tcp";
        host = "any";
      }
      # all -> all, Required only for Flannel VXLAN
      {
        port = "8472";
        proto = "udp";
        host = "any";
      }
      # all -> all, Kubelet metrics and API
      {
        port = "10250";
        proto = "tcp";
        host = "any";
      }
      # all -> all, Required only for Flannel Wireguard with IPv4
      {
        port = "51820";
        proto = "udp";
        host = "any";
      }
      # all -> all, Required only for Flannel Wireguard with IPv6
      {
        port = "51821";
        proto = "udp";
        host = "any";
      }
      # all -> all,	Required only for embedded distributed registry (Spegel)
      {
        port = "5001";
        proto = "tcp";
        host = "any";
      }
      # idem
      {
        port = "6443";
        proto = "tcp";
        host = "any";
      }
    ];

    # Let’s use k3s. Much simpler, apparently.
    services.k3s = {
      enable = true;
      role = if cfg.master.enable then "server" else "agent";
      nodeIP = config.marinfra.info.nebula_address;
      tokenFile = "/secret/k3s-secret";
      extraFlags = (if cfg.master.enable then [
        "--cluster-cidr=10.200.0.0/16"
      ] else []) ++ [
        "--embedded-registry"
        #TODO: the full P2P registry stuff
      ];
    } // (if cfg.master.clusterInit then {
      clusterInit = true;
    } else {
      serverAddr = "https://zana.local:6443";
    });



    #TODO: move this a marinfra syncthing module
    services.syncthing.settings.folders = {
      "/raspiconfig-downstream" = {
        id = "txuv9-adhsr";
        devices = [ "mariuspc" ];
        label = "raspiconfig";
        type = "receiveonly";
      };
    };

    systemd.tmpfiles.rules = [
      "d '/raspiconfig-downstream' 700 dokuwiki_pool dokuwiki_pool -"
    ];

    environment.variables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    # Rook
    boot.kernelModules = [ "ceph" "rbd" ];

    systemd.services.containerd.serviceConfig = {
      LimitNOFILE = lib.mkForce null;
    };
  };
}
