{ pkgs, lib, ... }:

{
    systemd.services.autoupdate = {
        description = "auto update";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        path = [
            pkgs.nixUnstable
            (pkgs.nixos-rebuild.override {
                nix = pkgs.nixUnstable;
            })
        ];

        script = ''
            ${pkgs.python3}/bin/python ${./controller.py}
        '';
    };
}