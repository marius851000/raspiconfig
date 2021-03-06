{ pkgs, ... }:

{
    services.restic = {
        backups = {
            toazure = {
                repository = "rclone:tardigrade:/hacknews-backup/"; #azurebloc::/backup
                rcloneConfig = {
                    type = "tardigrade";
                    satellite_address = "12L9ZFwhzVpuEKMUNUqkaTLGzwY9G24tbiigLiXpmZWKwmcNDDs@europe-west-1.tardigrade.io:7777";
                };
                rcloneConfigFile = "/secret-tardigrate-rclone-config.conf";
                #TODO: actually use a proper secret management system (or at least put them all in a folder)
                passwordFile = "/restic-password";
                initialize = true;
                extraBackupArgs = [
                    "--exclude=/nix"
                    "--exclude=/proc"
                    "--exclude=/tmp"
                    "--exclude=/run"
                    "--exclude=/boot"
                    "--exclude=/sys"
                    "--exclude=/dev"
                    "--exclude=/var/log"
                    "--exclude=/var/cache"
                    "--exclude=/swapfile"
                ];
                paths = [
                    "/"
                ];
            };
        };
    };
}