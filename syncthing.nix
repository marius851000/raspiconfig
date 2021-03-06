{ pkgs, ...}:

{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = true;
    overrideDevices = true;
    user = "dokuwiki_pool";
    devices = {
      "mariuspc" = { id = "5DV5CNV-RINTS7A-QRW7NB2-HVESTUX-4PL7NTS-7SCY7Q2-56ZZGTU-H6LOCQV"; };
    };
    folders = {
      "hacknews-site" = {
        id = "hacknews-sitefolder";
        path = "/site";
        devices = [ "mariuspc" ];
        ignorePerms = true;
      };
    };
  };
}