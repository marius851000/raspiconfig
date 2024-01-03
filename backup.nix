{ pkgs, ... }:

{
    services.restic = {
        backups = {
            toazure = {
                initialize = true;
                repository = "rclone:tardigrade:/hacknews-backup/"; #azurebloc::/backup
                rcloneConfig = {
                    type = "tardigrade";
                    satellite_address = "12L9ZFwhzVpuEKMUNUqkaTLGzwY9G24tbiigLiXpmZWKwmcNDDs@europe-west-1.tardigrade.io:7777";
                };
                rcloneConfigFile = "/secret/restic-tardigrade-config.conf";
                #TODO: actually use a proper secret management system (or at least put them all in a folder)
                passwordFile = "/secret/restic-password";
                #initialize = true;
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
                    "--exclude=/peertube-mount-home"
                    "--exclude=/old-root"
                    "--exclude=/var/lib/mastodon/public-system/cache"
                    "--exclude=/var/lib/peertube-mount/hacknews-peertube/streaming-playlists"
                    "--exclude=/var/lib/peertube-mount/hacknews-peertube/redundancy"
                    "--exclude=/portbuild/mirror"
                    "--exclude=/portbuild/cache"
                    "--exclude=/portbuild/morrowind"
                    "--exclude=/nexusback"
                    "-vvvv"
                ];
                paths = [
                    "/"
                ];
            };
        };
    };
}