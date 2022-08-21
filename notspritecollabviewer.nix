{ spritecollab_srv-src, pmdcollab_wiki-src }:

{ pkgs, config, ... }:

let
  server = pkgs.rustPlatform.buildRustPackage rec {
    pname = "spritecollab_srv";
    version = "git";

    src = spritecollab_srv-src;

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];

    prePatch = ''
      substituteInPlace src/main.rs \
        --replace 3000 3001
    '';

    cargoSha256 = "sha256-4wUSLjSqA1suRW8qoeCvNLVBF2s84fxJxtPjf0GYWKM=";
  };
in

{
  systemd.services.notspriteserver = {
    enable = true;
    description = "graphql for NotSpriteCollab";
    wantedBy = [ "multi-user.target" ];
    wants = [ "redis-notspriteserver.service" ];
    environment = {
      RUST_LOG = "spritecollab_srv=debug";
      RUST_BACKTRACE = "1";
      SCSRV_ADDRESS = "https://nss.pmdcollab.org";
      SCSRV_GIT_REPO = "https://github.com/marius851000/NotSpriteCollab.git";
      SCSRV_GIT_ASSETS_URL = "https://nsc.pmdcollab.org/spritecollab";
      SCSRV_WORKDIR = "/workdirnotspriteserver";
      SCSRV_REDIS_HOST = "127.0.0.1";
      SCSRV_REDIS_PORT = "6387";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${server}/bin/spritecollab-srv";
      Restart = "on-failure";
      RestartSec = 60;
      User = "nginx";
      Group = "nginx"; #TODO: put them in a different (independant) user
    };
  };

  systemd.tmpfiles.rules = [
    "d '/workdirnotspriteserver' 700 nginx nginx -"
  ];

  services.redis.servers.notspriteserver = {
    enable = true;
    openFirewall = false;
    port = 6387;
    save = [];
    appendOnly = false;
  };
  services.redis.vmOverCommit = true;

  services.nginx = {
    enable = true;

    virtualHosts."nss.pmdcollab.org" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:3001";
      };
    };

    virtualHosts."notspriteserver.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      extraConfig = "return 301 https://nss.pmdcollab.org$request_uri;";
    };

    virtualHosts."notspritecollab.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      extraConfig = "return 301 https://nsc.pmdcollab.org$request_uri;";
    };

    virtualHosts."nsc.pmdcollab.org" = {
      root = "/workdirnotspriteserver";
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        alias = "${(pkgs.callPackage ./packages/pmdcollab-wiki.nix { inherit pmdcollab_wiki-src; url = "https://nsc.pmdcollab.org"; graphql_endpoint = "https://nss.pmdcollab.org/graphql"; })}/";
        extraConfig = ''
          add_header 'Access-Control-Allow-Origin' '*'  always;
          add_header 'Access-Control-Max-Age' '3600'  always;
          add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
          add_header 'Access-Control-Allow-Headers' '*' always;
          autoindex on;
        '';
      };

      locations."/spritecollab" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
