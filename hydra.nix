{ hostname }:

{ lib, config, pkgs, ... }:

{
  marinfra.ssl.extraDomain = [ hostname ];

  services.nginx = {
    virtualHosts."${hostname}" = {
      locations."/" = {
        proxyPass = "http://localhost:3010";
      };
    };
  };

  services.hydra = {
    enable = true;
    useSubstitutes = true;
    port = 3010;
    minimumDiskFreeEvaluator = 10;
    minimumDiskFree = 10;
    listenHost = "localhost";
    hydraURL = hostname;
    buildMachinesFiles = [];
    notificationSender = "hydra@mariusdavid.fr";
    extraConfig = ''
      allow_import_from_derivation = true
      <git-input>
        timeout = 99990
      </git-input>
    '';
  };

  nix.settings = {
    allow-import-from-derivation = true;
  };

  nix.package = pkgs.nixVersions.latest;

  nix.extraOptions = ''
    allowed-uris = https://github.com/ https://gitlab.com github: gitlab: path:/nix/store
  '';

  nix.settings.extra-sandbox-paths = [ /* "/portbuild" "/nexusback" */ ];
}
