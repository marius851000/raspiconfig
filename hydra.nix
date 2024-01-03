{ lib, config , ... }:

{
  marinfra.ssl.extraDomain = [ "hydra.mariusdavid.fr" ];

  services.nginx = {
    virtualHosts."hydra.mariusdavid.fr" = {
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    };
  };

  services.hydra = {
    enable = true;
    useSubstitutes = true;
    port = 3000;
    minimumDiskFreeEvaluator = 10;
    minimumDiskFree = 10;
    listenHost = "localhost";
    hydraURL = "hydra.mariusdavid.fr";
    buildMachinesFiles = [];
    notificationSender = "hydra@mariusdavid.fr";
    extraConfig = ''
      <git-input>
        timeout = 99990
      </git-input>
    '';
  };

  nix.extraOptions = ''
    allowed-uris = https://github.com/ https://gitlab.com
  '';

  nix.settings.extra-sandbox-paths = [ "/portbuild" "/nexusback" ];
}