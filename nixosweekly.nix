{ pmdsite }:

{ pkgs, lib, ... }:

let
    site = pmdsite.packages.aarch64-linux.site;
in {
    services.nginx = {
        enable = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;

        virtualHosts.localhost = {
            root = site;
        };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
}