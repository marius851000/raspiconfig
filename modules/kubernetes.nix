{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.kubernetes;

  kubeMasterIP = "200:6233:ac7:f76c:ef8f:e313:aa1:b882";
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;

  trusted_ips = [
    "200:6233:ac7:f76c:ef8f:e313:aa1:b882" # noctus
    "202:3679:f712:fd04:e3de:a123:caf4:580d" # marella
    "200:deb5:f162:56a0:b1d0:fee:6a44:9980" #TUF pc
  ];
in {
  options.marinfra.kubernetes = {
    enable = lib.mkEnableOption "Enable Kubernetes";

    master = {
      enable = lib.mkEnableOption "Enable Kubernetes master";
    };
  };

  config = let
    api = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
  in lib.mkIf cfg.enable {

    networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

    networking.firewall.extraCommands = (lib.concatLines (builtins.map (ip6: ''
      #TODO: put that ssh in its own file
      ip6tables -s ${ip6} -A INPUT -p tcp --dport 22 -j ACCEPT # ssh
      ip6tables -s ${ip6} -A INPUT -p udp --dport 22 -j ACCEPT # ssh

      ip6tables -s ${ip6} -A INPUT -p tcp --dport 8888 -j ACCEPT # kubeapi
      ip6tables -s ${ip6} -A INPUT -p udp --dport 8888 -j ACCEPT # kubeapi

      ip6tables -s ${ip6} -A INPUT -p tcp --dport 6443 -j ACCEPT # kubeapi
      ip6tables -s ${ip6} -A INPUT -p udp --dport 6443 -j ACCEPT # kubeapi

      ip6tables -s ${ip6} -A INPUT -p udp --dport 8285 -j ACCEPT # flannel
      ip6tables -s ${ip6} -A INPUT -p udp --dport 8472 -j ACCEPT # flannel
    '') trusted_ips)) + 
    #TODO: seems weird we need to specifify that. Will need to spend some time to figure out why.
    ''
      ip6tables -s fd98::/15 -A INPUT -p tcp -j ACCEPT
      ip6tables -s fe80::/64 -A INPUT -p tcp -j ACCEPT # Why do we need that?
      ip6tables -s fd99::/112 -A INPUT -p tcp -j ACCEPT 
    '';

    # packages for administration tasks
    environment.systemPackages = with pkgs; [
      kompose
      kubectl
      kubernetes
      kubernetes-helm
      helmfile
    ];

    services.kubernetes = {
      roles = (lib.optionals cfg.master.enable [ "master" ]) ++ [ "node"];
      masterAddress = kubeMasterHostname;
      apiserverAddress = api;
      easyCerts = true;
      apiserver = {
        securePort = kubeMasterAPIServerPort;
        advertiseAddress = kubeMasterIP;
      };

      # use coredns
      addons.dns.enable = true;      
      kubelet.extraOpts = "--fail-swap-on=false";

      #flannel.enable = true;
      #flannel.openFirewallPorts = false;

      apiserver.serviceClusterIpRange = "fd99::0/112";
      addons.dns.clusterIp = "fd99::fffe";

      apiserver.authorizationMode = [ "AlwaysAllow" ]; #TODO: not secure (thought would be ok with the firewall for now). Flannel complain about some missing authorisation.

      /*addonManager.bootstrapAddons.flannel-cr.rules = [
        {
          apiGroups = [ "" ];
          resources = [ "nodes" ];
          verbs = [
            "get"
          ];
        }
      ];*/

      clusterCidr = "fd98::/64";
      #The difference between cluster-cidr and node-cidr-mask-size-ipv6 cannot be more than 16 bits. (for some reason?)
      #https://github.com/k3s-io/k3s/discussions/7889
      #controllerManager.extraOpts = " --node-cidr-mask-size 30 ";


      # needed if you use swap
    } // (if (!cfg.master.enable) then { #TODO: how do I merge dict?
      kubelet.kubeconfig.server = api;
      kubelet.extraOpts = "--fail-swap-on=false";
    } else {});

    /*systemd.services.kubelet.preStart = lib.mkForce ''
      ${lib.concatMapStrings (img: ''
        echo "Seeding container image: ${img}"
        ${
          if (lib.hasSuffix "gz" img) then
            ''${pkgs.gzip}/bin/zcat "${img}" | ${pkgs.containerd}/bin/ctr -n k8s.io image import --platform x86_64 -''
          else
            ''${pkgs.coreutils}/bin/cat "${img}" | ${pkgs.containerd}/bin/ctr -n k8s.io image import --platform x86_64 -''
        }
      '') config.services.kubernetes.kubelet.seedDockerImages}

      rm /opt/cni/bin/* || true
      ${lib.concatMapStrings (package: ''
        echo "Linking cni package: ${package}"
        ln -fs ${package}/bin/* /opt/cni/bin
      '') config.services.kubernetes.kubelet.cni.packages}
    '';*/

    systemd.services.kubelet.serviceConfig.TimeoutStartSec = "600s";

    services.flannel = {
    #  subnetLen = 64;
    #  network = "10.0.0.0/31"; #TODO: this is required to be a valid, make nullable
      extraNetworkConfig = {
        EnableIPv4 = false;
        EnableIPv6 = true;
        #TODO: was: fd98
        IPv6Network = "fd98::/15";
        Network = ""; # might have to be set to null
      };
      #TODO: fix

      iface = "tun0";
    };


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

    # Rook

    boot.kernelModules = [ "ceph" ];

    systemd.services.containerd.serviceConfig = {
      LimitNOFILE = lib.mkForce null;
    };
  };
}
