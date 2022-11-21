{ retoot-bot-src }:

{ pkgs, ... }:

let
  retoot-bot = pkgs.python3Packages.buildPythonPackage {
    src = retoot-bot-src;
    pname = "retoot-bot";
    version = "git";

    format = "other";

    propagatedBuildInputs = [ pkgs.python3Packages.mastodon-py ];

    installPhase = ''
      mkdir -p $out/bin
      echo \#!/bin/python > $out/bin/retoot-bot
      cat main.py >> $out/bin/retoot-bot
      chmod +x $out/bin/retoot-bot
    '';
  };
  
  storage_dir = "/var/retoot-bot";
  user = "retoot-bot";
  group = "retoot-bot";
in
{
  environment.systemPackages = [ retoot-bot ];

  systemd.services = {
    retoot-bot = {
      description = "Mastodon retooter bot";
      wantedBy = [ "multi-user.target" ];

      environment = {
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          PYTHONUNBUFFERED = "true";
      };

      confinement.enable = true;
      confinement.packages = [ pkgs.cacert ];

      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "startretootbot" ''
          #!${pkgs.bash}/bin/bash
          ${retoot-bot}/bin/retoot-bot ${storage_dir}/config.json
        '';
        Restart = "always";
        RestartSec = "10s";
        User = user;
        Group = group;

        BindPaths="${storage_dir}";
        BindReadOnlyPaths="/etc";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d '${storage_dir}' 700 ${user} ${group} -"
  ];

  users.users."${user}" = {
    description = "Retoot bot user";
    group = group;
    isSystemUser = true;
  };

  users.groups."${group}" = { };
}
