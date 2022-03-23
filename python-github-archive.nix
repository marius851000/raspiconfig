{ mach-nix, python-github-archive_src, system }:

{ pkgs, ... }:

#Okay, so it didn't have any depencies actually. Anyway, that's overkill, but who care (spoiler: probably the non-existing CI)
let
  python-github-archive = mach-nix.lib."${system}".buildPythonApplication {
    src = python-github-archive_src;
  };
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
    #TODO: average systemd hardening
    services = {
      backup_github = {
        description = "backup github data";
        path = [ pkgs.git ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeScript "backup-github.sh" ''
            #!${pkgs.bash}/bin/bash
            export GITHUB_TOKEN=$(cat /secret-github-bot-token.txt)
            ${python-github-archive}/bin/github-backup SkyTemple --organization --output-directory /githubback --token $GITHUB_TOKEN -i --repositories --fork
          '';
        };
      };
    };
  };
}