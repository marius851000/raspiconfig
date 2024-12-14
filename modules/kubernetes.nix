{ lib, config, pkgs, ... }:

let
  cfg = config.marinfra.kubernetes;

  kubeMasterIP = "200:6233:ac7:f76c:ef8f:e313:aa1:b882";
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;
in {
  options.marinfra.kubernetes = {
    enable = lib.mkEnableOption "Enable Kubernetes";

    master = {
      enable = lib.mkEnableOption "Enable Kubernetes master";
    };
  };

  config = lib.mkIf cfg.enable {

    networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

    # packages for administration tasks
    environment.systemPackages = with pkgs; [
      kompose
      kubectl
      kubernetes
    ];

    services.kubernetes = {
      roles = (lib.optionals cfg.master.enable [ "master" ]) ++ [ "node"];
      masterAddress = kubeMasterHostname;
      apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
      easyCerts = true;
      apiserver = {
        securePort = kubeMasterAPIServerPort;
        advertiseAddress = kubeMasterIP;
      };

      flannel.enable = true;
      flannel.openFirewallPorts = false;

      apiserver.serviceClusterIpRange = "0200::/112";
      clusterCidr = "fd98::/108";
      controllerManager.extraOpts = " --node-cidr-mask-size 112 ";

      # use coredns
      addons.dns.enable = true;

      # needed if you use swap
      kubelet.extraOpts = "--fail-swap-on=false";
    };

    systemd.services.kubelet.preStart = lib.mkForce ''
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
    '';

    services.flannel = {
      subnetLen = 108;
      network = "10.0.0.0/31"; #TODO: this is required to be a valid, make nullable
      extraNetworkConfig = {
        EnableIPv4 = false;
        EnableIPv6 = true;
        IPv6Network = "fd98::/108";
      };
    };
  };
}