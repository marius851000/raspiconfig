{ config, ... }:

{
  systemd.tmpfiles.rules = [
    "d /secret 111 root root"
    "f /secret/restic-tardigrade-config.conf 700 root root"
    "f /secret/restic-password 700 root root"
  ];
}