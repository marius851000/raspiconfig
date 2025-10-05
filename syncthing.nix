{ pkgs, ...}:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = true;
    overrideDevices = true;
    user = "dokuwiki_pool"; #TODO: make this it’s own user and rely on group instead
    settings.devices = {
      "mariuspc" = { id = "5DV5CNV-RINTS7A-QRW7NB2-HVESTUX-4PL7NTS-7SCY7Q2-56ZZGTU-H6LOCQV"; };
      "coryn" = { id = "UIX2SV2-7QWSEVO-7H2ZER2-V5BT4T4-UCNBSYF-CG6GBE6-RWCOVQ7-VF4VJQP"; };
      "marella" = { id = "V6F5IEJ-JZBIHOE-3TWO4FM-VHPM5ZK-WBVYIM4-PFWAALL-MILXYKK-DYHUZQR"; };
      "zana" = { id = "J5RMTP6-MAJIXWN-Y7OEFF4-FXVHY6G-EC2W5UH-EMMAL4G-BH4NIYM-27QUIA5"; };
    };
    settings.urAccepted = true;
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
