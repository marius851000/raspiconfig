{ mariussite }:

{ pkgs, ... }:

let
  mariussite_instanced = import "${mariussite}/site.nix" { inherit pkgs; };
in
{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."mariusdavid.fr" = {
      root = mariussite_instanced;
      #TODO: Do not use machine certificate due to the mailserver
      enableACME = true;
      forceSSL = true;

      locations = {
        "= /.well-known/matrix/server" = {
          extraConfig =
            let
              # use 443 instead of the default 8448 port to unite
              # the client-server and server-server port for simplicity
              server."m.server" = "matrix.mariusdavid.fr:443";
            in
            ''
              add_header Content-Type application/json;
              return 200 '${builtins.toJSON server}';
            '';
        };
        "= /.well-known/matrix/client" = {
          extraConfig =
            let
              client = {
                "m.homeserver" = { "base_url" = "https://matrix.mariusdavid.fr"; };
                "m.identity_server" = { "base_url" = "https://vector.im"; };
              };
              # ACAO required to allow element-web on any URL to request this json file
            in
            ''
              add_header Content-Type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '${builtins.toJSON client}';
            '';
        };
        "/element/" = {
          alias = let
            element = pkgs.element-web.override {
            conf = {
              default_server_config = {
                "m.homeserver" = {
                  "base_url" = "https://mariusdavid.fr";
                  "server_name" = "mariusdavid.fr";
                };
              };
              disable_guests = true;
            };
          };
        in
          "${element}/";
          extraConfig = ''
            add_header X-Frame-Options SAMEORIGIN;
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header Content-Security-Policy "frame-ancestors 'none'";
          '';
        };
        "= /element" = {
          return = "https://mariusdavid.fr/element/";
        };
      };
    };

    /*virtualHosts."reddit1.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;
    };

    virtualHosts."reddit2.mariusdavid.fr" = {
      root = "/dev/null";
      enableACME = true;
      forceSSL = true;
    };*/
  };

  services.syncthing.settings.folders.dragons = {
    id = "dragons";
    path = "/dragons";
    devices = [ "mariuspc" ];
    ignorePerms = true;
  };
}
