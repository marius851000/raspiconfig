{ pkgs, ...}:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = true;
    overrideDevices = true;
    user = "dokuwiki_pool";
    settings.devices = {
      "mariuspc" = { id = "5DV5CNV-RINTS7A-QRW7NB2-HVESTUX-4PL7NTS-7SCY7Q2-56ZZGTU-H6LOCQV"; };
    };
  };

  systemd.tmpfiles.rules = [
    "d '/var/lib/syncthing' 700 dokuwiki_pool dokuwiki_pool -"
  ];

  users.groups.dokuwiki_pool = {};
  users.users.dokuwiki_pool = {
    isSystemUser = true;
    group = "dokuwiki_pool";
  };
}