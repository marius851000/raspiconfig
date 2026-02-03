{ lib, pkgs, config, ... }:

let
  cfg = config.marinfra.machine-site;
in {
  options.marinfra.machine-site = {
    enable = lib.mkEnableOption "Per-machine test site";

    domain = lib.mkOption {
      default = "${config.networking.hostName}.net.mariusdavid.fr";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      virtualHosts."${cfg.domain}" = {
        enableACME = lib.mkDefault false;
        forceSSL = lib.mkDefault false;
        root = pkgs.stdenvNoCC.mkDerivation {
          name = "${config.networking.hostName}-base-site";

          nativeBuildInputs = [ pkgs.openssl ];

          dontUnpack = true;

          installPhase = ''
            mkdir $out
            echo "welcome to the ${config.networking.hostName} server." > $out/index.html
            echo "aaa" > seed.bin
            openssl rand -rand seed.bin -out $out/random.bin 10485760
          '';
        };
      };
    };
  };
}
