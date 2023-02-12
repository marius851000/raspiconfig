{ kodionline, system }:

{ pkgs, ... }:

let
  user = "kodionline";
  group = "kodionline";
  kodi_path = "/var/lib/kodionline/kodi";

  config = {
    plugins_to_show = [
      ["Arte Replay" "plugin://plugin.video.arteplussept/?"]
    ];
    kodi_path = kodi_path;
    python_command = "python3"; #TODO: do not require this value to be present
    #TODO: better, more dynamic handling of this
    default_user_config = {
		  language_order = ["fr" "en"];
		  resolution_order = ["1080p" "720p" "480p" "360p"];
		  format_order = ["mp4" "webm"];
	  };
    #TODO: auto-add kod_path
    allowed_path = [ ];
  };
  #TODO: make my code also handle package management

  configFile = pkgs.writeText "kodionline-config.json" (
    builtins.toJSON config
  );
in
{
  systemd.services = {
    kodionline = {
      description = "Kodi online";
      wantedBy = [ "multi-user.target" ];

      environment = {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        ROCKET_PORT = "1659";
      };

      confinement.enable = true;
      confinement.packages = [ pkgs.cacert ];

      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "startkodionline" ''
          #!${pkgs.bash}/bin/bash
          ${kodionline.packages."${system}".kodionline}/bin/kodionline -c ${configFile}
        '';
        Restart = "always";
        RestartSec = "10s";
        User = user;
        Group = group;

        BindReadOnlyPaths="/etc ${kodi_path}";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d '${kodi_path}' 700 ${user} ${group} -"
  ];

  users.users."${user}" = {
    description = "Kodionline user";
    group = group;
    isSystemUser = true;
  };

  users.groups."${group}" = { };

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."kodi.mariusdavid.fr" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:1659";
        proxyWebsockets = true;
      };
    };
  };
}
