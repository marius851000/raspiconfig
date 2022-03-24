{ spritebot_src, ... }:
{ pkgs, ... }:

let
    storagePath = "/var/lib/notspritecollab";
    spritebot = pkgs.callPackage ./spritebot.nix {
        inherit storagePath;
        src = spritebot_src;
    };
    user = "Eaglace";
    group = "Eaglace";
    sshKeyLocation = "/secret-github-ssh";

    known_hosts = pkgs.writeText "known_hosts" ''github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg='';
in
{
    systemd.services.notspritecollabbot = {
        enable = true;
        description = "NotSpriteCollab Discord bot";
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.git pkgs.openssh ];
        environment = {
            GIT_SSH_COMMAND="ssh -i ${sshKeyLocation} -o 'UserKnownHostsFile ${known_hosts}'";
            GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };
        confinement.enable = true;
        confinement.fullUnit = true;
        confinement.packages = [ pkgs.cacert pkgs.git pkgs.openssh ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${spritebot}/bin/spritebot";
            Restart = "on-failure";
            RestartSec = 65;
            User = user;
            Group = group;

            BindPaths="${storagePath} ${storagePath}.private";
            BindReadOnlyPaths="${sshKeyLocation} /etc"; #TODO: try to get rid of /etc
            
            SystemCallArchitectures = "native";
            SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];

            #TODO: continue and learn more on this subject
        };
    };

    systemd.tmpfiles.rules = [
        "d '${storagePath}' 700 ${user} ${group} -"
        "d '${storagePath}.private' 700 ${user} ${group} -"
        "f '${sshKeyLocation}' 400 ${user} ${group} -"
        "f '${sshKeyLocation}.pub' 400 ${user} ${group} -"
    ];

    users.users."${user}" = {
        description = "NotSpriteBot user";
        group = group;
        isSystemUser = true;
    };

    users.groups."${group}" = {};

    #TODO: put this in his own flake -- maybe upstream, in the spritebot repo
}