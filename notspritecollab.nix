{ spritebot_src, ... }:
{ pkgs, ... }:

let
    spritebot = pkgs.callPackage ./spritebot.nix {
        storagePath = "/notspritecollab";
        src = spritebot_src;
    };
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
        };
    };
}