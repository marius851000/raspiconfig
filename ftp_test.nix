{ config, pkgs, ... }:

{
  services.vsftpd.enable = true;
  services.vsftpd.anonymousUser = true;
  services.vsftpd.userlistEnable = true;
  services.vsftpd.userlist = [ "marius" "root" ];
}
