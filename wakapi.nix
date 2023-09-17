{ pkgs, ... }:

let
  package = pkgs.wakapi; #pkgs.callPackage ./wakapi_package.nix { inherit wakapi_src; };

  stateDir = "wakapi";
in
{
  users.users.wakapi = {
    group = "wakapi";
    isSystemUser = true;
  };
  users.groups.wakapi = {};

  # from https://github.com/NotAShelf/nyx/blob/77be2f440132a768a80227f18cf25dc6a33dd1bf/modules/extra/shared/nixos/wakapi/default.nix#L71

  systemd.services.wakapi = {
    after = ["network.target"];
    #path = with pkgs; [openssl];
    serviceConfig = {
      User = "wakapi";
      Group = "wakapi";
      #EnvironmentFile = [configFile];
      ExecStart = "${package}/bin/wakapi";
      LimitNOFILE = "1048576";
      PrivateTmp = "true";
      PrivateDevices = "true";
      ProtectHome = "true";
      ProtectSystem = "strict";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      StateDirectory = "${stateDir}";
      WorkingDirectory = "/var/lib/${stateDir}";
      StateDirectoryMode = "0700";
      Restart = "always";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.tmpfiles.rules = [
    "D /var/lib/${stateDir}/data 755 wakapi wakapi - -"
  ];

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

  #networking.firewall.allowedTCPPorts = [ 3000 ];
}
