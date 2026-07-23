{ pkgs, config, lib, ... }:

let
  custom_dns_server = pkgs.rustPlatform.buildRustPackage {
    pname = "custom_dns_server";
    version = "na";

    src = ./custom-dns-server;

    cargoLock = {
      lockFile = ./custom-dns-server/Cargo.lock;
    };
  };
in
{
  marinfra.ssl.extraDomain = [ "ceph.mariusdavid.fr" ];

  systemd.services.custom_dns_server_for_ceph = let
    machine_mapping_arg = builtins.concatStringsSep " " (
      builtins.map (
        m: if m.value.options.marinfra.nebula.enable.value then
          "--mapping ${m.name} ${m.value.options.marinfra.info.nebula_address.value}"
        else
          ""
      ) (lib.attrsToList config.marinfra.info.all_machines)
    );
  in {
    enable = true;
    description = "Custom DNS server to locate CEPH MGR server";
    wantedBy = [ "multi-user.target" ];
    environment = {
      PATH = pkgs.lib.mkForce (lib.makeBinPath [ pkgs.ceph-client ]);
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${custom_dns_server}/bin/custom-dns-server --port 9253 ${machine_mapping_arg}";
      Restart = "on-failure";
      RestartSec = 30;
    };
  };

  services.nginx = {
    virtualHosts."ceph.mariusdavid.fr" = {
      basicAuthFile = "/secret-nginx-auth";
      locations."/" = {

        proxyPass = "http://$ceph_upstream:9080";
        extraConfig = ''
          resolver 127.0.0.1:9253 ipv6=off valid=10s;
          set $ceph_upstream "ceph-mgr.local";
        '';
      };
    };
  };
}
