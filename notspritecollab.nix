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
in
{
    systemd.services.notspritecollabbot = {
        enable = true;
        description = "NotSpriteCollab Discord bot";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${spritebot}/bin/spritebot";
            Restart = "on-failure";
            RestartSec = 65;
            User = user;
            Group = group;
        };
    };

    systemd.tmpfiles.rules = [
        "d '${storagePath}' 700 ${user} ${group} -"
        "d '${storagePath}.private' 700 ${user} ${group} -"
    ];

    users.users."${user}" = {
        description = "NotSpriteBot user";
        group = group;
        isSystemUser = true;
    };

    users.groups."${group}" = {};

    #TODO: put this in his own flake -- maybe upstream, in the spritebot repo
}