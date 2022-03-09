{ ... }:

{
  services.syncthing.relay = {
    enable = true;
    providedBy = "marius851000 OVH / FR";
    globalRateBps = 5000000;
  };

  networking.firewall.allowedTCPPorts = [ 22070 22067];
}