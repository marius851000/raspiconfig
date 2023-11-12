{hacky-account-manager, system }:
{ pkgs, ... }:

let
  folder = "/var/lib/hacky_account_manager";
  user = "hacky_account_manager";
  group = "hacky_account_manager";
in
{
  security.acme.certs."mariusdavid.fr".extraDomainNames = [ "boinc.mariusdavid.fr" ];

  services.nginx.virtualHosts."boinc.mariusdavid.fr" = {
    root = "/dev/null";
    useACMEHost = "mariusdavid.fr";
    enableACME = false;
    forceSSL = true;
    http3 = true;
    locations."/" = {
      proxyPass = "http://localhost:8080";
      proxyWebsockets = true;
    };
  };

  systemd.services.hacky-account-manager = {
        enable = true;
        description = "Hacky Account Manager";
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.git pkgs.openssh ];
        environment = {
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            RUST_LOG = "debug";
        };
        confinement.enable = true;
        confinement.fullUnit = true;
        confinement.packages = [ pkgs.cacert pkgs.git pkgs.openssh ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${hacky-account-manager.packages."${system}".boinc-account-manager-rs}/bin/boinc-accoung-manager-rs ${folder}/config.json ${folder}/db.sqlite";
            Restart = "on-failure";
            RestartSec = 65;
            User = user;
            Group = group;

            BindPaths="${folder}";
            BindReadOnlyPaths="/etc"; #TODO: try to get rid of /etc
        };
    };

  users.users."${user}" = {
    description = "Hacky account manager";
    group = group;
    isSystemUser = true;
  };

  users.groups."${group}" = {};

  systemd.tmpfiles.rules = [
    "d '${folder}' 700 ${user} ${group} -"
    "d '${folder}/signatures' 700 ${user} ${group} -"
  ];
}