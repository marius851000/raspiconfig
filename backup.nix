{ pkgs, config, ... }:

{
    #TODO: atomic backup (create a subvolume)
    services.restic = {
        backups = {
            root = {
                initialize = true;
                repository = "s3:https://s3.gra.io.cloud.ovh.net/backup-${config.marinfra.info.this_machine_key}";
                #TODO: actually use a proper secret management system (or at least put them all in a folder)
                passwordFile = "/secret/restic-password";
                environmentFile = "/secret/restic-secrets.txt";
                extraBackupArgs = [
                    "-o s3.bucket-lookup=path"
                    "-o s3.storage-class=STANDARD_IA"
                    "-o s3.region=\"gra\""

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
