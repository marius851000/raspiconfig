{ mach-nix, python-github-archive_src, system }:

{ pkgs, ... }:

#Okay, so it didn't have any depencies actually. Anyway, that's overkill, but who care (spoiler: probably the non-existing CI)
let
  python-github-archive = mach-nix.lib."${system}".buildPythonApplication {
    src = python-github-archive_src;
    pname = "python-github-archive";
    version = "git";
    requirements = builtins.readFile "${python-github-archive_src}/requirements.txt";
    ignoreDataOutdated = true;
  };

  tokenPath = "/secret-github-bot-token.txt";
  backupDir = "/githubback";

  user = "githubback";
  group = "githubback";
in
{
  environment.systemPackages = [ python-github-archive ];

  systemd = {
    timers = {
      backup_github = {
        description = "backup github data";
        timerConfig = {
          OnCalendar = "*-*-* *:00:00";
          Unit = "backup_github.service";
        };
        wantedBy = [ "timers.target" ];
      };
    };

    services = {
      backup_github = {
        description = "backup github data";
        path = [ pkgs.git ];

        environment = {
            GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };

        confinement.enable = true;
        confinement.packages = [ pkgs.cacert pkgs.git ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeScript "backup-github.sh" ''
            #!${pkgs.bash}/bin/bash
            export GITHUB_TOKEN=$(${pkgs.coreutils}/bin/cat ${tokenPath})
            ${python-github-archive}/bin/github-backup SkyTemple --organization --output-directory ${backupDir} --token $GITHUB_TOKEN -i --repositories --fork
          '';
          User = user;
          Group = group;

          BindPaths="${backupDir}";
          BindReadOnlyPaths="${tokenPath} /etc";
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "f '${tokenPath}' 400 ${user} ${group} -"
    "d '${backupDir}' 700 ${user} ${group} -"
  ];

  users.users."${user}" = {
    description = "NotSpriteBot user";
    group = group;
    isSystemUser = true;
  };

  users.groups."${group}" = { };
}
