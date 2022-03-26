{ wakapi_src }:
{ pkgs, ... }:

let
  wakapi = pkgs.callPackage ./wakapi_package.nix { inherit wakapi_src; };

  user = "wakapi";
  group = "wakapi";

  stateDir = "/var/lib/wakapi";
in
{
  environment.systemPackages = [ wakapi ];

  systemd.services.wakapi = {
    enable = true;
    description = "Wakapi activity tracker";
    wantedBy = [ "multi-user.target" ];
    
    environment = {
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
    confinement.enable = true;
    confinement.fullUnit = true;
    confinement.packages = [ pkgs.cacert ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${wakapi}/bin/wakapi";
      Restart = "on-failure";
      RestartSec = 65;

      User = user;
      Group = group;
      WorkingDirectory = stateDir;

      BindPaths = stateDir;
      BindReadOnlyPaths = "/etc"; #TODO: try to get rid of /etc

      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      ProtectProc = "invisibled";
      NoNewPrivileges = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      CapabilityBoundingSet = "";
      PrivateDevices = true;
      ProtectHostname = true;
      ProcSubset = "pid";
      RestrictNamespaces = true;

      #TODO: continue and learn more on this subject
    };
  };

  systemd.tmpfiles.rules = [
      "d '${stateDir}' 700 ${user} ${group} -"
  ];

  users.users."${user}" = {
    description = "NotSpriteBot user";
    group = group;
    isSystemUser = true;
  };

  users.groups."${group}" = {};

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."wakapi.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://[::1]:3000";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
