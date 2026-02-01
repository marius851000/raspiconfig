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
    package = pkgs.hydra.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        # Fix CORS
        (pkgs.fetchpatch {
          url = "https://github.com/NixOS/hydra/pull/1397.patch";
          sha256 = "sha256-u2k1Xhfg733ccBukn+I2L0UArFs/bkOqAu6ZPCW1oRM=";
        })
      ];
    });

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
      <git-input>
        timeout = 99990
      </git-input>
    '';
  };

  nix.package = pkgs.nixVersions.latest;

  nix.extraOptions = ''
    allowed-uris = https://github.com/ https://gitlab.com github: gitlab: path:/nix/store
  '';

  nix.settings.extra-sandbox-paths = [ /* "/portbuild" "/nexusback" */ ];
}
